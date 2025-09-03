# Urovo SDK ProGuard Rules
# Keep all Urovo device classes
-keep class android.device.** { *; }
-keep interface android.device.** { *; }

# Keep PrinterManager specifically
-keep class android.device.PrinterManager { *; }

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all public methods in our MainActivity
-keep class za.co.istreet.rycamera.MainActivity { *; }

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep method channel related classes
-keep class io.flutter.plugin.common.** { *; }