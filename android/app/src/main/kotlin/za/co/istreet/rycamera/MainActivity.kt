package za.co.istreet.rycamera

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.device.PrinterManager

class MainActivity : FlutterActivity() {
    private val UROVO_CHANNEL = "za.co.istreet.rycamera/printer"
    private val DEVICE_INFO_CHANNEL = "za.co.istreet.rycamera/device_info"
    private val UROVO_TAG = "UrovoPrinter"
    
    // Urovo printer
    private var printerManager: PrinterManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize Urovo printer
        initializeUrovoPrinter()
        
        // Urovo Printer Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UROVO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "printImage" -> {
                    val imageData = call.argument<ByteArray>("imageData")
                    val width = call.argument<Int>("width") ?: 384
                    val height = call.argument<Int>("height") ?: 0
                    
                    if (imageData != null) {
                        val success = printImageOnUrovo(imageData, width, height)
                        if (success) {
                            result.success("Image printed successfully on Urovo")
                        } else {
                            result.error("PRINT_ERROR", "Failed to print image on Urovo", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Image data is null", null)
                    }
                }
                "checkPrinterStatus" -> {
                    val status = checkUrovoStatus()
                    result.success(status)
                }
                "printTestPage" -> {
                    val success = printTestPageUrovo()
                    if (success) {
                        result.success("Test page printed on Urovo")
                    } else {
                        result.error("PRINT_ERROR", "Failed to print test page on Urovo", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Device Info Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_INFO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceModel" -> {
                    val deviceModel = "${Build.MANUFACTURER} ${Build.MODEL}".trim()
                    Log.i("DeviceInfo", "Device: $deviceModel")
                    result.success(deviceModel)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializeUrovoPrinter() {
        try {
            printerManager = PrinterManager()
            Log.i(UROVO_TAG, "PrinterManager initialized successfully")
            
            // Test the printer manager with a simple operation
            try {
                printerManager!!.clearPage()
                Log.i(UROVO_TAG, "PrinterManager test operation successful")
            } catch (testException: Exception) {
                Log.w(UROVO_TAG, "PrinterManager test operation failed: ${testException.message}")
            }
            
        } catch (e: Exception) {
            Log.e(UROVO_TAG, "Failed to initialize PrinterManager: ${e.message}", e)
            printerManager = null
        }
    }

    // UROVO PRINTER METHODS
    private fun printImageOnUrovo(imageData: ByteArray, width: Int, height: Int): Boolean {
        return try {
            Log.d(UROVO_TAG, "Attempting to print image with width: $width, height: $height")
            
            // Convert byte array to bitmap
            val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
            if (bitmap == null) {
                Log.e(UROVO_TAG, "Failed to decode bitmap from image data")
                return false
            }
            
            Log.i(UROVO_TAG, "Bitmap dimensions: ${bitmap.width}x${bitmap.height}")
            
            if (printerManager == null) {
                Log.e(UROVO_TAG, "PrinterManager is not initialized - attempting re-initialization")
                initializeUrovoPrinter()
                if (printerManager == null) {
                    Log.e(UROVO_TAG, "Re-initialization failed - PrinterManager still null")
                    return false
                }
            }
            
            try {
                // Setup page for thermal printer (58mm width = ~384 pixels)
                val setupResult = printerManager!!.setupPage(384, bitmap.height + 100)
                Log.i(UROVO_TAG, "Setup page result: $setupResult")
                
                // Draw bitmap at position (0, 10) with small margin
                val drawResult = printerManager!!.drawBitmap(bitmap, 0, 10)
                Log.i(UROVO_TAG, "Draw bitmap result: $drawResult")

                // Print the page
                val printResult = printerManager!!.printPage(0) // 0 = no rotation
                Log.i(UROVO_TAG, "Print result: $printResult")

                // Clear page after printing
                try {
                    printerManager!!.clearPage()
                    Log.i(UROVO_TAG, "Page cleared successfully")
                } catch (clearException: Exception) {
                    Log.w(UROVO_TAG, "Failed to clear page: ${clearException.message}")
                }

                return true // Return true if we got this far without exceptions
                
            } catch (printerException: Exception) {
                Log.e(UROVO_TAG, "Printer operation failed: ${printerException.message}", printerException)
                
                // Check if it's the "stub" error specifically
                if (printerException.message?.contains("stub") == true) {
                    Log.e(UROVO_TAG, "STUB ERROR: Urovo SDK methods are not properly available")
                    Log.e(UROVO_TAG, "This usually means the device doesn't support the printer or SDK is not properly integrated")
                }
                
                return false
            }
            
        } catch (e: Exception) {
            Log.e(UROVO_TAG, "Error printing image: ${e.message}", e)
            false
        }
    }

    private fun checkUrovoStatus(): String {
        return if (printerManager != null) "connected" else "disconnected"
    }

    private fun printTestPageUrovo(): Boolean {
        return try {
            if (printerManager == null) {
                initializeUrovoPrinter()
                if (printerManager == null) return false
            }
            
            printerManager!!.setupPage(384, 200)
            // Add some test text or pattern here if needed
            printerManager!!.printPage(0)
            printerManager!!.clearPage()
            true
        } catch (e: Exception) {
            Log.e(UROVO_TAG, "Error printing test page: ${e.message}", e)
            false
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up resources
        printerManager = null
    }
}
