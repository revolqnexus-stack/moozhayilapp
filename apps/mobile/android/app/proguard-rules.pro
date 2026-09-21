# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core (optional deferred components — referenced by Flutter embedding)
-dontwarn com.google.android.play.core.**

# Razorpay
-keepclassmembers class com.razorpay.** { *; }
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Firebase / FCM
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Hive
-keep class com.hive.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Gson (used by some Flutter plugins)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

# General — preserve line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
