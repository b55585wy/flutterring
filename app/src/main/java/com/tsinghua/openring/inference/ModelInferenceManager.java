package com.tsinghua.openring.inference;

import android.content.Context;
import android.util.Log;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.pytorch.IValue;
import org.pytorch.Module;
import org.pytorch.Tensor;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ModelInferenceManager {
    public enum Mission { HR, BP_SYS, BP_DIA, SPO2 }

    public interface Listener {
        void onHrPredicted(int bpm);
        void onBpSysPredicted(int mmHg);
        void onBpDiaPredicted(int mmHg);
        void onSpo2Predicted(int percent);
    }

    private static final String TAG = "ModelInference";
    private final Context appContext;
    private final Listener listener;
    private final ObjectMapper mapper = new ObjectMapper();

    private final Map<Mission, List<Module>> missionModules = new HashMap<>();
    private final Map<Mission, JsonNode> missionConfigs = new HashMap<>();

    private final int sampleRateHz = 25;
    private int windowSeconds = 5;

    private final ArrayDeque<Float> greenBuf = new ArrayDeque<>();
    private final ArrayDeque<Float> irBuf = new ArrayDeque<>();

    public ModelInferenceManager(Context context, Listener listener) {
        this.appContext = context.getApplicationContext();
        this.listener = listener;
    }

    public void init() {
        // Try load four missions. Assets are mapped to app/models/** by Gradle.
        loadMission(Mission.HR, findFirstMissionRoot("hr"));
        loadMission(Mission.BP_SYS, findFirstMissionRoot("BP_sys"));
        loadMission(Mission.BP_DIA, findFirstMissionRoot("BP_dia"));
        loadMission(Mission.SPO2, findFirstMissionRoot("spo2"));

        // Infer windowSeconds from first available config
        for (JsonNode cfg : missionConfigs.values()) {
            if (cfg != null && cfg.has("window_seconds")) {
                try {
                    windowSeconds = Math.max(1, cfg.get("window_seconds").asInt());
                    break;
                } catch (Exception ignored) {}
            }
        }
        Log.i(TAG, "Initialized. WindowSeconds=" + windowSeconds);
    }

    private String findFirstMissionRoot(String missionKey) {
        // Known roots under assets (mapped from app/models): try common patterns
        // Assets are packaged with 'models' as a source root, but the AssetManager paths are root-relative.
        String[] roots = new String[] {
                "transformer-ring1-hr-all-ir/hr",
                "transformer-ring1-hr-all-irred/hr",
                "transformer-ring1-bp-all-irred/" + missionKey,
                "transformer-ring1-spo2-all-irred/spo2"
        };
        for (String r : roots) {
            try {
                String[] files = appContext.getAssets().list(r);
                if (files != null && files.length > 0) {
                    // Heuristic: ensure this root path matches the missionKey
                    if (r.endsWith("/" + missionKey) || r.endsWith("/hr") || r.endsWith("/spo2")) {
                        return r;
                    }
                }
            } catch (IOException ignored) {}
        }
        return null;
    }

    public String reportStatus() {
        StringBuilder sb = new StringBuilder();
        for (Mission m : Mission.values()) {
            List<Module> list = missionModules.get(m);
            int n = (list == null) ? 0 : list.size();
            sb.append("[Model] ").append(m.name()).append(": folds=").append(n).append('\n');
        }
        return sb.toString();
    }

    private void loadMission(Mission mission, String missionRoot) {
        if (missionRoot == null) {
            Log.w(TAG, "Mission root not found: " + mission);
            return;
        }
        try {
            String[] subDirs = appContext.getAssets().list(missionRoot);
            if (subDirs == null) return;

            // Each Fold-X contains a json and a pt file
            List<Module> modules = new ArrayList<>();
            for (String sub : subDirs) {
                String foldDir = missionRoot + "/" + sub;
                String[] foldFiles = appContext.getAssets().list(foldDir);
                if (foldFiles == null) continue;

                String jsonPath = null;
                String ptPath = null;
                for (String f : foldFiles) {
                    if (f.endsWith(".json")) jsonPath = foldDir + "/" + f;
                    if (f.endsWith(".pt")) ptPath = foldDir + "/" + f;
                }
                if (jsonPath != null && ptPath != null) {
                    // Load config (only once per mission, prefer first)
                    if (!missionConfigs.containsKey(mission)) {
                        try (InputStream is = appContext.getAssets().open(jsonPath)) {
                            missionConfigs.put(mission, mapper.readTree(is));
                        } catch (Exception e) {
                            Log.w(TAG, "Failed reading config: " + jsonPath, e);
                        }
                    }
                    try {
                        String localPath = AssetsUtils.assetFilePath(appContext, ptPath);
                        Module m = Module.load(localPath);
                        modules.add(m);
                        Log.i(TAG, "Loaded module: " + ptPath);
                    } catch (Throwable t) {
                        Log.w(TAG, "Skip module (load failed): " + ptPath, t);
                    }
                }
            }
            if (!modules.isEmpty()) {
                missionModules.put(mission, modules);
                Log.i(TAG, "Mission " + mission + " folds loaded: " + modules.size());
            }
        } catch (IOException e) {
            Log.e(TAG, "Error loading mission: " + mission, e);
        }
    }

    public void onSensorData(long green, long red, long ir, short accX, short accY, short accZ, long timestampMs) {
        // Buffer only what we need (green, ir)
        greenBuf.addLast((float) green);
        irBuf.addLast((float) ir);
        int maxSize = windowSeconds * sampleRateHz;
        while (greenBuf.size() > maxSize) greenBuf.removeFirst();
        while (irBuf.size() > maxSize) irBuf.removeFirst();

        if (greenBuf.size() == maxSize && irBuf.size() == maxSize) {
            runAllMissions();
        }
    }

    private void runAllMissions() {
        // Prepare input tensor [1, T, C] with C=2 (green, ir)
        int T = greenBuf.size();
        float[] input = new float[T * 2];
        int i = 0;
        for (Float v : greenBuf) { input[i * 2] = v; i++; }
        i = 0;
        for (Float v : irBuf) { input[i * 2 + 1] = v; i++; }

        // normalize per-channel (zero mean, unit var) for numerical stability
        normalizeInPlace(input, 2, T);

        long[] shape = new long[]{1, T, 2};
        Tensor tensor = Tensor.fromBlob(input, shape);

        // HR
        if (hasMission(Mission.HR)) {
            float pred = averagePrediction(missionModules.get(Mission.HR), tensor);
            if (listener != null && !Float.isNaN(pred) && pred > 0) {
                listener.onHrPredicted(Math.round(pred));
            }
        }
        // BP SYS
        if (hasMission(Mission.BP_SYS)) {
            float pred = averagePrediction(missionModules.get(Mission.BP_SYS), tensor);
            if (listener != null && !Float.isNaN(pred) && pred > 0) {
                listener.onBpSysPredicted(Math.round(pred));
            }
        }
        // BP DIA
        if (hasMission(Mission.BP_DIA)) {
            float pred = averagePrediction(missionModules.get(Mission.BP_DIA), tensor);
            if (listener != null && !Float.isNaN(pred) && pred > 0) {
                listener.onBpDiaPredicted(Math.round(pred));
            }
        }
        // SpO2
        if (hasMission(Mission.SPO2)) {
            float pred = averagePrediction(missionModules.get(Mission.SPO2), tensor);
            if (listener != null && !Float.isNaN(pred) && pred > 0) {
                int val = Math.max(70, Math.min(100, Math.round(pred)));
                listener.onSpo2Predicted(val);
            }
        }
    }

    private boolean hasMission(Mission m) {
        List<Module> list = missionModules.get(m);
        return list != null && !list.isEmpty();
    }

    private float averagePrediction(List<Module> modules, Tensor input) {
        if (modules == null || modules.isEmpty()) return Float.NaN;
        float sum = 0f;
        int n = 0;
        for (Module m : modules) {
            try {
                IValue out = m.forward(IValue.from(input));
                Tensor t = out.toTensor();
                float[] arr = t.getDataAsFloatArray();
                if (arr.length > 0) {
                    sum += arr[arr.length - 1]; // support either scalar or last-step output
                    n++;
                }
            } catch (Throwable e) {
                Log.w(TAG, "Forward failed on one fold", e);
            }
        }
        return n > 0 ? sum / n : Float.NaN;
    }

    private void normalizeInPlace(float[] data, int channels, int T) {
        for (int c = 0; c < channels; c++) {
            double mean = 0;
            for (int t = 0; t < T; t++) {
                mean += data[t * channels + c];
            }
            mean /= T;
            double var = 0;
            for (int t = 0; t < T; t++) {
                double v = data[t * channels + c] - mean;
                var += v * v;
            }
            double std = Math.sqrt(var / Math.max(1, T - 1));
            if (std < 1e-6) std = 1.0;
            for (int t = 0; t < T; t++) {
                data[t * channels + c] = (float) ((data[t * channels + c] - mean) / std);
            }
        }
    }
}


