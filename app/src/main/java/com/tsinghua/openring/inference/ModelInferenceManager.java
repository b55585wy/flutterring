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
        default void onDebugLog(String message) {}
    }

    private static final String TAG = "ModelInference";
    private final Context appContext;
    private final Listener listener;
    private final ObjectMapper mapper = new ObjectMapper();

    private final Map<Mission, List<Module>> missionModules = new HashMap<>();
    private final Map<Mission, JsonNode> missionConfigs = new HashMap<>();

    private final int sampleRateHz = 25;
    private int windowSeconds = 5;
    private int targetFs = 100;

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

        inferWindowAndTargetFs();
        logDebug("Initialized. WindowSeconds=" + windowSeconds + ", targetFs=" + targetFs);
    }

    private void inferWindowAndTargetFs() {
        for (JsonNode cfg : missionConfigs.values()) {
            if (cfg == null) continue;
            JsonNode dataset = cfg.get("dataset");
            if (dataset != null) {
                if (dataset.has("window_duration")) {
                    try {
                        windowSeconds = Math.max(5, dataset.get("window_duration").asInt());
                    } catch (Exception ignored) {}
                }
                if (dataset.has("target_fs")) {
                    try {
                        targetFs = Math.max(sampleRateHz, dataset.get("target_fs").asInt());
                    } catch (Exception ignored) {}
                }
            }
        }
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
                            logDebug("Failed reading config: " + jsonPath + " - " + e.getMessage());
                        }
                    }
                    try {
                        String localPath = AssetsUtils.assetFilePath(appContext, ptPath);
                        Module m = Module.load(localPath);
                        modules.add(m);
                        Log.i(TAG, "Loaded module: " + ptPath);
                        logDebug("Loaded module: " + ptPath);
                    } catch (Throwable t) {
                        Log.w(TAG, "Skip module (load failed): " + ptPath, t);
                        logDebug("Model load failed for " + ptPath + ": " + t.getMessage());
                    }
                }
            }
            if (!modules.isEmpty()) {
                missionModules.put(mission, modules);
                Log.i(TAG, "Mission " + mission + " folds loaded: " + modules.size());
                logDebug("Mission " + mission + " folds loaded: " + modules.size());
            }
        } catch (IOException e) {
            Log.e(TAG, "Error loading mission: " + mission, e);
            logDebug("Error loading mission " + mission + ": " + e.getMessage());
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
        // Prepare input tensor [1, C, T] with C=2 (green, ir)
        int targetLength = windowSeconds * targetFs;
        if (targetLength <= 0) {
            logDebug("Target length invalid: " + targetLength);
            return;
        }

        float[] resampledGreen = resampleBuffer(greenBuf, targetLength);
        float[] resampledIr = resampleBuffer(irBuf, targetLength);
        if (resampledGreen == null || resampledIr == null) {
            logDebug("Resample failed due to insufficient data");
            return;
        }

        float[] input = new float[targetLength * 2];
        for (int i = 0; i < targetLength; i++) {
            input[i] = resampledGreen[i]; // channel 0
            input[targetLength + i] = resampledIr[i]; // channel 1
        }

        // normalize per-channel (zero mean, unit var) for numerical stability
        normalizeInPlace(input, targetLength);

        long[] shape = new long[]{1, 2, targetLength};
        Tensor tensor = Tensor.fromBlob(input, shape);
        logDebug("Inference window ready: targetLength=" + targetLength);

        // HR
        if (hasMission(Mission.HR)) {
            float pred = averagePrediction(missionModules.get(Mission.HR), tensor);
            if (listener != null && !Float.isNaN(pred) && pred > 0) {
                listener.onHrPredicted(Math.round(pred));
            }
            if (Float.isNaN(pred)) logDebug("HR prediction NaN");
        }
        // BP SYS
        if (hasMission(Mission.BP_SYS)) {
            float pred = averagePrediction(missionModules.get(Mission.BP_SYS), tensor);
            if (listener != null && !Float.isNaN(pred) && pred > 0) {
                listener.onBpSysPredicted(Math.round(pred));
            }
            if (Float.isNaN(pred)) logDebug("BP_SYS prediction NaN");
        }
        // BP DIA
        if (hasMission(Mission.BP_DIA)) {
            float pred = averagePrediction(missionModules.get(Mission.BP_DIA), tensor);
            if (listener != null && !Float.isNaN(pred) && pred > 0) {
                listener.onBpDiaPredicted(Math.round(pred));
            }
            if (Float.isNaN(pred)) logDebug("BP_DIA prediction NaN");
        }
        // SpO2
        if (hasMission(Mission.SPO2)) {
            float pred = averagePrediction(missionModules.get(Mission.SPO2), tensor);
            if (listener != null && !Float.isNaN(pred) && pred > 0) {
                int val = Math.max(70, Math.min(100, Math.round(pred)));
                listener.onSpo2Predicted(val);
            }
            if (Float.isNaN(pred)) logDebug("SpO2 prediction NaN");
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
                if (arr.length == 0) logDebug("Empty output tensor from module");
            } catch (Throwable e) {
                Log.w(TAG, "Forward failed on one fold", e);
                 logDebug("Forward failed: " + e.getMessage());
            }
        }
        return n > 0 ? sum / n : Float.NaN;
    }

    private float[] resampleBuffer(ArrayDeque<Float> buffer, int targetLength) {
        int srcSize = buffer.size();
        if (srcSize < 2 || targetLength < 2) {
            return null;
        }
        float[] src = new float[srcSize];
        int idx = 0;
        for (Float v : buffer) {
            src[idx++] = v;
        }

        float[] out = new float[targetLength];
        float ratio = (float) sampleRateHz / targetFs;
        for (int i = 0; i < targetLength; i++) {
            float srcPos = i * ratio;
            int idx0 = (int) Math.floor(srcPos);
            int idx1 = Math.min(srcSize - 1, idx0 + 1);
            float frac = srcPos - idx0;
            if (idx0 >= srcSize) {
                out[i] = src[srcSize - 1];
            } else {
                float v0 = src[idx0];
                float v1 = src[idx1];
                out[i] = v0 + (v1 - v0) * frac;
            }
        }
        return out;
    }

    private void normalizeInPlace(float[] data, int lengthPerChannel) {
        int channels = 2;
        for (int c = 0; c < channels; c++) {
            int offset = c * lengthPerChannel;
            double mean = 0;
            for (int t = 0; t < lengthPerChannel; t++) {
                mean += data[offset + t];
            }
            mean /= lengthPerChannel;
            double var = 0;
            for (int t = 0; t < lengthPerChannel; t++) {
                double v = data[offset + t] - mean;
                var += v * v;
            }
            double std = Math.sqrt(var / Math.max(1, lengthPerChannel - 1));
            if (std < 1e-6) std = 1.0;
            for (int t = 0; t < lengthPerChannel; t++) {
                data[offset + t] = (float) ((data[offset + t] - mean) / std);
            }
        }
    }

    private void logDebug(String message) {
        if (listener != null) {
            listener.onDebugLog(message);
        }
    }
}


