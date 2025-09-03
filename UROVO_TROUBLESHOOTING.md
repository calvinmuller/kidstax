# Urovo i9100 PrinterManager Troubleshooting

## "Stub" Error in Release Mode

If you encounter a `java.lang.RuntimeException: stub` error when printing in release mode, this indicates that the Urovo SDK methods are not properly available at runtime.

### Possible Causes & Solutions:

#### 1. ProGuard/R8 Obfuscation
The release build process may be obfuscating the Urovo SDK classes.

**Solution**: The app is already configured with:
- `isMinifyEnabled = false` 
- `isShrinkResources = false`
- ProGuard rules in `proguard-rules.pro` to protect Urovo classes

#### 2. JitPack Dependency Issues
The JitPack repository dependency may not include all necessary native libraries.

**Solution**: Replace JitPack dependency with official Urovo JAR files:

1. Download `platform_sdk_v4.1.0326.jar` from Urovo's official SDK
2. Place it in `android/app/libs/` directory
3. Update `android/app/build.gradle.kts`:
   ```kotlin
   dependencies {
       // Replace JitPack with local JAR
       implementation(files("libs/platform_sdk_v4.1.0326.jar"))
       // implementation("com.github.urovosamples:usdk:4.1.5")  // Comment out
   }
   ```

#### 3. Device-Specific Issues
The error may occur if:
- The device doesn't have the built-in printer functionality
- The firmware doesn't support the PrinterManager SDK
- The app doesn't have proper permissions

**Check**: Run `adb logcat | grep UrovoPrinter` to see detailed error messages.

#### 4. Alternative Approach: Use Urovo's Intent-Based Printing
If the SDK continues to fail, you can use Android Intents to communicate with Urovo's built-in printing service:

```kotlin
private fun printViaIntent(imagePath: String) {
    try {
        val intent = Intent("urovo.print.action")
        intent.putExtra("image_path", imagePath)
        startActivity(intent)
    } catch (e: Exception) {
        Log.e(TAG, "Intent-based printing failed: ${e.message}")
    }
}
```

## Current Status

The app includes:
- ✅ Robust error handling and logging
- ✅ ProGuard protection for Urovo classes  
- ✅ Fallback to save processed images when printing fails
- ✅ Clear user feedback about printing status

## Next Steps

1. Test the current release APK on actual Urovo i9100 hardware
2. Check Android logs for specific error details
3. Contact Urovo support if stub errors persist
4. Consider using local SDK JAR files as backup solution