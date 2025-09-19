package com.tsinghua.openring.utils;

import android.util.Log;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Real-time Heart Rate and Respiratory Rate Processing
 * Processes PPG and accelerometer data to calculate vital signs
 */
public class VitalSignsProcessor {
    private static final String TAG = "VitalSignsProcessor";
    
    // Configuration constants
    private static final int SAMPLE_RATE = 25; // Hz - based on your ring's sampling rate
    private static final int HR_WINDOW_SIZE = SAMPLE_RATE * 8; // 8 seconds for HR calculation
    private static final int RR_WINDOW_SIZE = SAMPLE_RATE * 30; // 30 seconds for RR calculation
    private static final int MIN_PEAKS_FOR_HR = 3; // Minimum peaks needed for HR calculation
    private static final int MIN_PEAKS_FOR_RR = 2; // Minimum peaks needed for RR calculation
    
    // Heart rate range constraints (BPM)
    private static final int MIN_HR_BPM = 40;
    private static final int MAX_HR_BPM = 200;
    
    // Respiratory rate range constraints (RPM)
    private static final int MIN_RR_RPM = 8;
    private static final int MAX_RR_RPM = 40;
    
    // Data buffers for processing
    private final List<Long> ppgGreenBuffer = new ArrayList<>();
    private final List<Long> ppgIrBuffer = new ArrayList<>();
    private final List<Short> accXBuffer = new ArrayList<>();
    private final List<Short> accYBuffer = new ArrayList<>();
    private final List<Short> accZBuffer = new ArrayList<>();
    private final List<Long> timestampBuffer = new ArrayList<>();
    
    // Current vital signs
    private volatile int currentHeartRate = -1;
    private volatile int currentRespiratoryRate = -1;
    private volatile SignalQuality currentSignalQuality = SignalQuality.POOR;
    private volatile long lastUpdateTime = 0;
    
    // Callback interface for vital signs updates
    public interface VitalSignsCallback {
        void onHeartRateUpdate(int heartRate);
        void onRespiratoryRateUpdate(int respiratoryRate);
        void onSignalQualityUpdate(SignalQuality quality);
    }
    
    public enum SignalQuality {
        EXCELLENT("Excellent", "#4CAF50"),
        GOOD("Good", "#8BC34A"),
        FAIR("Fair", "#FFC107"),
        POOR("Poor", "#FF5722"),
        NO_SIGNAL("No Signal", "#9E9E9E");
        
        private final String displayName;
        private final String color;
        
        SignalQuality(String displayName, String color) {
            this.displayName = displayName;
            this.color = color;
        }
        
        public String getDisplayName() { return displayName; }
        public String getColor() { return color; }
    }
    
    private VitalSignsCallback callback;
    
    public VitalSignsProcessor(VitalSignsCallback callback) {
        this.callback = callback;
    }
    
    /**
     * Add new sensor data point for processing
     */
    public synchronized void addDataPoint(long green, long ir, short accX, short accY, short accZ, long timestamp) {
        // Add data to buffers
        ppgGreenBuffer.add(green);
        ppgIrBuffer.add(ir);
        accXBuffer.add(accX);
        accYBuffer.add(accY);
        accZBuffer.add(accZ);
        timestampBuffer.add(timestamp);
        
        // Maintain buffer size for HR calculation
        if (ppgGreenBuffer.size() > HR_WINDOW_SIZE) {
            ppgGreenBuffer.remove(0);
            ppgIrBuffer.remove(0);
            timestampBuffer.remove(0);
        }
        
        // Maintain buffer size for RR calculation
        if (accXBuffer.size() > RR_WINDOW_SIZE) {
            accXBuffer.remove(0);
            accYBuffer.remove(0);
            accZBuffer.remove(0);
        }
        
        // Process vital signs if we have enough data
        if (ppgGreenBuffer.size() >= HR_WINDOW_SIZE) {
            processHeartRate();
        }
        
        if (accXBuffer.size() >= RR_WINDOW_SIZE) {
            processRespiratoryRate();
        }
        
        // Update signal quality
        updateSignalQuality();
        
        lastUpdateTime = System.currentTimeMillis();
    }
    
    /**
     * Process heart rate from PPG data using peak detection
     */
    private void processHeartRate() {
        try {
            // Use Green PPG for heart rate calculation (typically best signal)
            List<Long> ppgData = new ArrayList<>(ppgGreenBuffer);
            
            // Apply basic filtering
            List<Double> filteredPPG = applyBandpassFilter(ppgData, 0.5, 4.0); // 0.5-4Hz for HR
            
            // Detect peaks
            List<Integer> peaks = detectPeaks(filteredPPG, 0.6); // 60% threshold
            
            if (peaks.size() >= MIN_PEAKS_FOR_HR) {
                // Calculate intervals between peaks
                List<Double> intervals = new ArrayList<>();
                for (int i = 1; i < peaks.size(); i++) {
                    double interval = (peaks.get(i) - peaks.get(i-1)) / (double) SAMPLE_RATE;
                    intervals.add(interval);
                }
                
                // Calculate median interval for robustness
                Collections.sort(intervals);
                double medianInterval = intervals.get(intervals.size() / 2);
                
                // Convert to BPM
                int heartRate = (int) Math.round(60.0 / medianInterval);
                
                // Validate heart rate range
                if (heartRate >= MIN_HR_BPM && heartRate <= MAX_HR_BPM) {
                    if (currentHeartRate != heartRate) {
                        currentHeartRate = heartRate;
                        if (callback != null) {
                            callback.onHeartRateUpdate(heartRate);
                        }
                        Log.d(TAG, "Heart Rate Updated: " + heartRate + " BPM");
                    }
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error processing heart rate", e);
        }
    }
    
    /**
     * Process respiratory rate from accelerometer data
     */
    private void processRespiratoryRate() {
        try {
            // Calculate magnitude of acceleration vector
            List<Double> accMagnitude = new ArrayList<>();
            for (int i = 0; i < accXBuffer.size(); i++) {
                double x = accXBuffer.get(i);
                double y = accYBuffer.get(i);
                double z = accZBuffer.get(i);
                double magnitude = Math.sqrt(x*x + y*y + z*z);
                accMagnitude.add(magnitude);
            }
            
            // Apply low-pass filter for respiratory rate (0.1-0.7Hz)
            List<Double> filteredAcc = applyBandpassFilter(accMagnitude, 0.1, 0.7);
            
            // Detect peaks for respiratory cycles
            List<Integer> peaks = detectPeaks(filteredAcc, 0.4); // 40% threshold
            
            if (peaks.size() >= MIN_PEAKS_FOR_RR) {
                // Calculate respiratory rate from peak intervals
                double totalTime = RR_WINDOW_SIZE / (double) SAMPLE_RATE; // Total time in seconds
                int respiratoryRate = (int) Math.round((peaks.size() - 1) * 60.0 / totalTime);
                
                // Validate respiratory rate range
                if (respiratoryRate >= MIN_RR_RPM && respiratoryRate <= MAX_RR_RPM) {
                    if (currentRespiratoryRate != respiratoryRate) {
                        currentRespiratoryRate = respiratoryRate;
                        if (callback != null) {
                            callback.onRespiratoryRateUpdate(respiratoryRate);
                        }
                        Log.d(TAG, "Respiratory Rate Updated: " + respiratoryRate + " RPM");
                    }
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error processing respiratory rate", e);
        }
    }
    
    /**
     * Simple bandpass filter implementation
     */
    private List<Double> applyBandpassFilter(List<? extends Number> data, double lowFreq, double highFreq) {
        List<Double> filtered = new ArrayList<>();
        
        // Simple moving average for demonstration (replace with proper filter if needed)
        int windowSize = Math.max(1, SAMPLE_RATE / 5); // 0.2 second window
        
        for (int i = 0; i < data.size(); i++) {
            double sum = 0;
            int count = 0;
            
            int start = Math.max(0, i - windowSize/2);
            int end = Math.min(data.size(), i + windowSize/2 + 1);
            
            for (int j = start; j < end; j++) {
                sum += data.get(j).doubleValue();
                count++;
            }
            
            filtered.add(sum / count);
        }
        
        return filtered;
    }
    
    /**
     * Peak detection using threshold-based approach
     */
    private List<Integer> detectPeaks(List<Double> data, double threshold) {
        List<Integer> peaks = new ArrayList<>();
        
        if (data.size() < 3) return peaks;
        
        // Calculate dynamic threshold based on data range
        double min = Collections.min(data);
        double max = Collections.max(data);
        double dynamicThreshold = min + (max - min) * threshold;
        
        // Find peaks
        for (int i = 1; i < data.size() - 1; i++) {
            double current = data.get(i);
            double prev = data.get(i - 1);
            double next = data.get(i + 1);
            
            // Peak criteria: local maximum above threshold
            if (current > prev && current > next && current > dynamicThreshold) {
                // Avoid peaks too close together (minimum distance)
                if (peaks.isEmpty() || i - peaks.get(peaks.size() - 1) > SAMPLE_RATE / 4) {
                    peaks.add(i);
                }
            }
        }
        
        return peaks;
    }
    
    /**
     * Update signal quality based on data characteristics
     */
    private void updateSignalQuality() {
        SignalQuality quality = SignalQuality.NO_SIGNAL;
        
        if (!ppgGreenBuffer.isEmpty()) {
            // Calculate signal-to-noise ratio
            long min = Collections.min(ppgGreenBuffer);
            long max = Collections.max(ppgGreenBuffer);
            double range = max - min;
            double mean = ppgGreenBuffer.stream().mapToLong(Long::longValue).average().orElse(0);
            
            // Simple quality assessment based on signal range and mean
            if (mean > 1000 && range > 500) {
                if (range > 2000) {
                    quality = SignalQuality.EXCELLENT;
                } else if (range > 1500) {
                    quality = SignalQuality.GOOD;
                } else if (range > 1000) {
                    quality = SignalQuality.FAIR;
                } else {
                    quality = SignalQuality.POOR;
                }
            } else {
                quality = SignalQuality.POOR;
            }
        }
        
        if (currentSignalQuality != quality) {
            currentSignalQuality = quality;
            if (callback != null) {
                callback.onSignalQualityUpdate(quality);
            }
        }
    }
    
    /**
     * Clear all buffers and reset state
     */
    public synchronized void reset() {
        ppgGreenBuffer.clear();
        ppgIrBuffer.clear();
        accXBuffer.clear();
        accYBuffer.clear();
        accZBuffer.clear();
        timestampBuffer.clear();
        
        currentHeartRate = -1;
        currentRespiratoryRate = -1;
        currentSignalQuality = SignalQuality.NO_SIGNAL;
        lastUpdateTime = 0;
        
        Log.d(TAG, "VitalSignsProcessor reset");
    }
    
    // Getters for current values
    public int getCurrentHeartRate() { return currentHeartRate; }
    public int getCurrentRespiratoryRate() { return currentRespiratoryRate; }
    public SignalQuality getCurrentSignalQuality() { return currentSignalQuality; }
    public long getLastUpdateTime() { return lastUpdateTime; }
    
    /**
     * Get buffer sizes for debugging
     */
    public String getBufferStatus() {
        return String.format("PPG: %d/%d, ACC: %d/%d", 
                ppgGreenBuffer.size(), HR_WINDOW_SIZE,
                accXBuffer.size(), RR_WINDOW_SIZE);
    }
}
