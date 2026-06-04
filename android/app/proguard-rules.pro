#Android ProGuard configuration for Flutter
#This file is used by the Android build system to perform code shrinking, optimization, and obfuscation.

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Spotify
-keep class com.spotify.** { *; }

# Keep native methods
-keepclassmembers class * {
    @java.lang.annotation.Retention(value = java.lang.annotation.RetentionPolicy.RUNTIME)
    <methods>
    </methods>
}

# Keep R classes
-keep class **.R$* { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep MainActivity
-keep class com.AntoineCFR.trackit.MainActivity { *; }
-keep class com.AntoineCFR.trackit.Application { *; }

# Keep for reflection
-keepattributes Signature
-keepattributes *Annotation*
-keep class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private <fields>;
    private <methods>;
}
