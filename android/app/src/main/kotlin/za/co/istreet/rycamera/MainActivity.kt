package za.co.istreet.rycamera

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.device.PrinterManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "za.co.istreet.rycamera/printer"
    private val TAG = "UrovoPrinter"
    
    private var printerManager: PrinterManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize the Urovo PrinterManager
        initializePrinter()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "printImage" -> {
                    val imageData = call.argument<ByteArray>("imageData")
                    val width = call.argument<Int>("width") ?: 384
                    val height = call.argument<Int>("height") ?: 0
                    
                    if (imageData != null) {
                        val success = printImageOnUrovo(imageData, width, height)
                        if (success) {
                            result.success("Image printed successfully")
                        } else {
                            result.error("PRINT_ERROR", "Failed to print image", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Image data is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializePrinter() {
        try {
            printerManager = PrinterManager()
            Log.i(TAG, "PrinterManager initialized successfully")
            
            // Test the printer manager with a simple operation
            try {
                printerManager!!.clearPage()
                Log.i(TAG, "PrinterManager test operation successful")
            } catch (testException: Exception) {
                Log.w(TAG, "PrinterManager test operation failed: ${testException.message}")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize PrinterManager: ${e.message}", e)
            printerManager = null
        }
    }

    private fun printImageOnUrovo(imageData: ByteArray, width: Int, height: Int): Boolean {
        return try {
            Log.d(TAG, "Attempting to print image with width: $width, height: $height")
            
            // Convert byte array to bitmap
            val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
            if (bitmap == null) {
                Log.e(TAG, "Failed to decode bitmap from image data")
                return false
            }
            
            Log.i(TAG, "Bitmap dimensions: ${bitmap.width}x${bitmap.height}")
            
            if (printerManager == null) {
                Log.e(TAG, "PrinterManager is not initialized - attempting re-initialization")
                initializePrinter()
                if (printerManager == null) {
                    Log.e(TAG, "Re-initialization failed - PrinterManager still null")
                    return false
                }
            }
            
            try {
                // Setup page for thermal printer (58mm width = ~384 pixels)
                val setupResult = printerManager!!.setupPage(384, bitmap.height + 100)
                Log.i(TAG, "Setup page result: $setupResult")
                
                // Draw bitmap at position (0, 10) with small margin
                val drawResult = printerManager!!.drawBitmap(bitmap, 0, 10)
                Log.i(TAG, "Draw bitmap result: $drawResult")

                // Print the page
                val printResult = printerManager!!.printPage(0) // 0 = no rotation
                Log.i(TAG, "Print result: $printResult")

                // Clear page after printing
                try {
                    printerManager!!.clearPage()
                    Log.i(TAG, "Page cleared successfully")
                } catch (clearException: Exception) {
                    Log.w(TAG, "Failed to clear page: ${clearException.message}")
                }

                return true // Return true if we got this far without exceptions
                
            } catch (printerException: Exception) {
                Log.e(TAG, "Printer operation failed: ${printerException.message}", printerException)
                
                // Check if it's the "stub" error specifically
                if (printerException.message?.contains("stub") == true) {
                    Log.e(TAG, "STUB ERROR: Urovo SDK methods are not properly available")
                    Log.e(TAG, "This usually means the device doesn't support the printer or SDK is not properly integrated")
                }
                
                return false
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error printing image: ${e.message}", e)
            false
        }
    }
}
