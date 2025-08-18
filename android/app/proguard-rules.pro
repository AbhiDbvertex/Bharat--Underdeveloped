# Preserve Razorpay classes
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Preserve GPay (Google Pay) integration classes
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**

# Optional annotations (safe to include)
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
