# R8 / ProGuard rules for the release build. Keep this file TARGETED: no blanket "-keep class **".
# Plugins ship their own consumer rules (Firebase, Google Maps, Geolocator, image_picker, Flutter engine),
# so only what a plugin documents as missing belongs here. Verify with a real release build + the
# critical flows (login, Razorpay payment, push, Maps, Places, image picker, invoice download).

# --- Razorpay checkout (razorpay_flutter -> com.razorpay:checkout). Rules from Razorpay's Android
#     ProGuard guidance: the SDK talks to its WebView via reflection/JavascriptInterface and calls back
#     onPayment* methods by name. ---
-keepattributes *Annotation*
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class com.razorpay.** { *; }
-keepclasseswithmembers class * {
    public void onPayment*(...);
}
-optimizations !method/inlining/*
# Razorpay references annotation classes it does not bundle; only these two are suppressed.
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
-dontwarn com.razorpay.**
