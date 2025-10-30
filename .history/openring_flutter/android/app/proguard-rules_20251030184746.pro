# Add project specific ProGuard rules here.
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Flutter ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ChipletRing SDK and LmSDK
-keep class com.lm.sdk.** { *; }
-dontwarn com.lm.sdk.**

# Optional dependencies - don't warn if missing
-dontwarn javax.ws.rs.**
-dontwarn rx.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn org.glassfish.jersey.**
-dontwarn retrofit2.adapter.rxjava.**
-dontwarn retrofit2.converter.fastjson.**
-dontwarn com.zhy.http.okhttp.**

# Keep FastJson
-keep class com.alibaba.fastjson.** { *; }
-dontwarn com.alibaba.fastjson.**

# Keep Retrofit
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Keep OkHttp
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep RxJava 2 and 3
-keep class io.reactivex.** { *; }
-dontwarn io.reactivex.**
-keep class io.reactivex.rxjava3.** { *; }
-dontwarn io.reactivex.rxjava3.**

# Keep Bluetooth classes
-keep class android.bluetooth.** { *; }

# Keep project utils
-keep class com.tsinghua.openring.utils.** { *; }

# Keep Gson
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep GreenDAO
-keep class org.greenrobot.greendao.** { *; }
-dontwarn org.greenrobot.greendao.**

# Keep Nordic BLE
-keep class no.nordicsemi.android.** { *; }
-dontwarn no.nordicsemi.android.**

# MMKV
-keep class com.tencent.mmkv.** { *; }
-dontwarn com.tencent.mmkv.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom views
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Keep service classes
-keep public class * extends android.app.Service

# Keep broadcast receivers
-keep public class * extends android.content.BroadcastReceiver

# Keep method channel classes
-keep class com.tsinghua.openring_flutter.** { *; }

