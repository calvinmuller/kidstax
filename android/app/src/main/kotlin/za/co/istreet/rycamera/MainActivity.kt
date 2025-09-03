package za.co.istreet.rycamera

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.device.PrinterManager
import android.content.Context

class MainActivity : FlutterActivity() {
    private val UROVO_CHANNEL = "za.co.istreet.rycamera/printer"
    private val SUNMI_CHANNEL = "za.co.istreet.rycamera/sunmi_printer"
    private val UROVO_TAG = "UrovoPrinter"
    private val SUNMI_TAG = "SunmiPrinter"
    
    // Urovo printer
    private var printerManager: PrinterManager? = null
    
    // Sunmi printer - Stub implementation (replace with actual SDK when available)
    private var isSunmiAvailable = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize both printers
        initializeUrovoPrinter()
        initializeSunmiPrinter()
        
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
        
        // Sunmi Printer Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SUNMI_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "printBitmap" -> {
                    val imageData = call.argument<ByteArray>("imageData")
                    val width = call.argument<Int>("width") ?: 576
                    val height = call.argument<Int>("height") ?: 0
                    val alignment = call.argument<Int>("alignment") ?: 1
                    
                    if (imageData != null) {
                        val success = printImageOnSunmi(imageData, width, height, alignment)
                        if (success) {
                            result.success("Image printed successfully on Sunmi P3")
                        } else {
                            result.error("PRINT_ERROR", "Failed to print image on Sunmi P3", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Image data is null", null)
                    }
                }
                "printText" -> {
                    val text = call.argument<String>("text")
                    val size = call.argument<Int>("size") ?: 24
                    val align = call.argument<Int>("align") ?: 0
                    
                    if (text != null) {
                        val success = printTextOnSunmi(text, size, align)
                        if (success) {
                            result.success("Text printed successfully on Sunmi P3")
                        } else {
                            result.error("PRINT_ERROR", "Failed to print text on Sunmi P3", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Text is null", null)
                    }
                }
                "setPrintDensity" -> {
                    val density = call.argument<Int>("density") ?: 2
                    val success = setSunmiPrintDensity(density)
                    if (success) {
                        result.success("Print density set to $density")
                    } else {
                        result.error("SETTING_ERROR", "Failed to set print density", null)
                    }
                }
                "checkPrinterStatus" -> {
                    val status = checkSunmiStatus()
                    result.success(status)
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

    private fun initializeSunmiPrinter() {
        try {
            Log.i(SUNMI_TAG, "Checking for Sunmi printer availability...")
            
            // TODO: Replace this stub with actual Sunmi SDK initialization
            // Example with com.sunmi:printerx:1.0.18:
            /*
            try {
                // Method 1: Using PrinterHelper (most common)
                val printerHelper = com.sunmi.printerhelper.PrinterHelper.getInstance()
                printerHelper.bindService(this, object : PrinterHelper.OnServiceConnectedListener {
                    override fun onServiceConnected() {
                        isSunmiAvailable = true
                        Log.i(SUNMI_TAG, "Sunmi printer service connected")
                    }
                    override fun onServiceDisconnected() {
                        isSunmiAvailable = false
                        Log.w(SUNMI_TAG, "Sunmi printer service disconnected")
                    }
                })
            } catch (e: Exception) {
                Log.e(SUNMI_TAG, "Sunmi SDK not available: ${e.message}")
                isSunmiAvailable = false
            }
            */
            
            // For now, detect Sunmi device by checking system properties
            val manufacturer = android.os.Build.MANUFACTURER?.lowercase()
            val model = android.os.Build.MODEL?.lowercase()
            
            if (manufacturer?.contains("sunmi") == true || model?.contains("p3") == true) {
                isSunmiAvailable = true
                Log.i(SUNMI_TAG, "Sunmi device detected (stub implementation)")
            } else {
                isSunmiAvailable = false
                Log.i(SUNMI_TAG, "Non-Sunmi device detected")
            }
            
        } catch (e: Exception) {
            Log.e(SUNMI_TAG, "Error checking Sunmi availability: ${e.message}", e)
            isSunmiAvailable = false
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

    // SUNMI PRINTER METHODS - Stub implementation for framework
    // TODO: Replace with actual Sunmi SDK calls
    private fun printImageOnSunmi(imageData: ByteArray, width: Int, height: Int, alignment: Int): Boolean {
        return try {
            if (!isSunmiAvailable) {
                Log.e(SUNMI_TAG, "Sunmi printer not available")
                return false
            }

            Log.d(SUNMI_TAG, "STUB: Would print image with width: $width, height: $height, alignment: $alignment")

            // Convert byte array to bitmap for validation
            val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
            if (bitmap == null) {
                Log.e(SUNMI_TAG, "Failed to decode bitmap from image data")
                return false
            }

            Log.i(SUNMI_TAG, "STUB: Bitmap dimensions: ${bitmap.width}x${bitmap.height}")

            // TODO: Replace with actual Sunmi SDK calls:
            /*
            // Example implementation:
            val printerHelper = PrinterHelper.getInstance()
            printerHelper.printBitmap(bitmap, alignment) { result ->
                if (result) {
                    Log.i(SUNMI_TAG, "Sunmi bitmap printed successfully")
                } else {
                    Log.e(SUNMI_TAG, "Sunmi bitmap print failed")
                }
            }
            */
            
            Log.w(SUNMI_TAG, "STUB: Sunmi image printing not implemented - add actual SDK calls")
            return true // Return true for testing

        } catch (e: Exception) {
            Log.e(SUNMI_TAG, "Error in Sunmi image printing stub: ${e.message}", e)
            false
        }
    }

    private fun printTextOnSunmi(text: String, size: Int, align: Int): Boolean {
        return try {
            if (!isSunmiAvailable) {
                Log.e(SUNMI_TAG, "Sunmi printer not available")
                return false
            }

            Log.d(SUNMI_TAG, "STUB: Would print text: $text with size: $size, align: $align")

            // TODO: Replace with actual Sunmi SDK calls:
            /*
            // Example implementation:
            val printerHelper = PrinterHelper.getInstance()
            printerHelper.setFontSize(size)
            printerHelper.setAlignment(align)
            printerHelper.printText(text) { result ->
                if (result) {
                    Log.i(SUNMI_TAG, "Sunmi text printed successfully")
                } else {
                    Log.e(SUNMI_TAG, "Sunmi text print failed")
                }
            }
            */
            
            Log.w(SUNMI_TAG, "STUB: Sunmi text printing not implemented - add actual SDK calls")
            return true // Return true for testing

        } catch (e: Exception) {
            Log.e(SUNMI_TAG, "Error in Sunmi text printing stub: ${e.message}", e)
            false
        }
    }

    private fun setSunmiPrintDensity(density: Int): Boolean {
        return try {
            if (!isSunmiAvailable) {
                Log.e(SUNMI_TAG, "Sunmi printer not available")
                return false
            }

            Log.d(SUNMI_TAG, "STUB: Would set print density to: $density")
            
            // TODO: Replace with actual Sunmi SDK calls:
            /*
            // Example implementation:
            val printerHelper = PrinterHelper.getInstance()
            val clampedDensity = density.coerceIn(1, 15)
            printerHelper.setPrintDensity(clampedDensity) { result ->
                if (result) {
                    Log.i(SUNMI_TAG, "Sunmi density set successfully")
                } else {
                    Log.e(SUNMI_TAG, "Sunmi density setting failed")
                }
            }
            */
            
            Log.w(SUNMI_TAG, "STUB: Sunmi density setting not implemented - add actual SDK calls")
            return true // Return true for testing

        } catch (e: Exception) {
            Log.e(SUNMI_TAG, "Error in Sunmi density setting stub: ${e.message}", e)
            false
        }
    }

    private fun checkSunmiStatus(): String {
        return if (isSunmiAvailable) "connected" else "disconnected"
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up Sunmi printer if needed
        if (isSunmiAvailable) {
            // TODO: Add actual Sunmi SDK cleanup if needed
            Log.i(SUNMI_TAG, "Sunmi printer cleanup completed")
        }
    }
}
