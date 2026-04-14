# Flutter local notifications — keep all receiver/service classes
-keep class com.dexterous.** { *; }

# Keep notification action callback entry point
-keep class * extends io.flutter.embedding.engine.FlutterEngine { *; }

# SQLite / sqflite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Timezone data
-keep class com.ibm.icu.** { *; }

# Keep all Flutter plugin registrants
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep go_router and provider reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Prevent stripping of classes used via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep Dart entry points
-keep class **.BuildConfig { *; }
