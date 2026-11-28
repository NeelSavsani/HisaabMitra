package com.example.hisaabmitra

import android.content.ClipData
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hisaabmitra/share")
            .setMethodCallHandler { call, result ->
                if (call.method != "shareTransactionImage") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val imageBytes = call.arguments as? ByteArray
                if (imageBytes == null) {
                    result.error("INVALID_IMAGE", "Transaction record image is missing.", null)
                    return@setMethodCallHandler
                }

                try {
                    val shareDirectory = File(cacheDir, "shared").apply { mkdirs() }
                    val imageFile = File(
                        shareDirectory,
                        "transaction_record_${System.currentTimeMillis()}.png",
                    )
                    imageFile.writeBytes(imageBytes)
                    val imageUri: Uri = FileProvider.getUriForFile(
                        this,
                        "$packageName.fileprovider",
                        imageFile,
                    )

                    val shareIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "image/png"
                        putExtra(Intent.EXTRA_STREAM, imageUri)
                        clipData = ClipData.newUri(contentResolver, "Transaction record", imageUri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    startActivity(Intent.createChooser(shareIntent, "Share image"))
                    result.success(null)
                } catch (error: Exception) {
                    result.error("SHARE_FAILED", error.message, null)
                }
            }
    }
}
