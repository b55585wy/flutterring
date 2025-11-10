package com.tsinghua.openring.utils;

import android.app.PendingIntent;

public class BLEUtils {
    private static boolean isConnecting = false;
    public static String contentTitle = "";
    public static PendingIntent pendingIntent = null;
    
    public static boolean isConnecting() {
        return isConnecting;
    }
    
    public static void setConnecting(boolean connecting) {
        isConnecting = connecting;
    }
}
