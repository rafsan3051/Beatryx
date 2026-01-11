package com.example.beatryx

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity
import android.content.ContentResolver
import android.content.ContentUris
import android.provider.MediaStore
import android.os.Build
import android.database.Cursor
import java.io.File

class MainActivity: AudioServiceActivity() {
    private val CHANNEL = "com.example.beatryx/files"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "deleteFile" -> {
                        val path = call.argument<String>("path")
                        if (path != null) {
                            val deleted = deleteAudioFile(path)
                            result.success(deleted)
                        } else {
                            result.error("INVALID_ARGUMENT", "Path is required", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun deleteAudioFile(path: String): Boolean {
        return try {
            val file = File(path)
            
            // First, try to delete from MediaStore by finding the ID
            try {
                val audioUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
                val selection = "${MediaStore.Audio.Media.DATA}=?"
                val selectionArgs = arrayOf(path)
                
                val cursor: Cursor? = contentResolver.query(
                    audioUri,
                    arrayOf(MediaStore.Audio.Media._ID),
                    selection,
                    selectionArgs,
                    null
                )
                
                if (cursor != null && cursor.moveToFirst()) {
                    val id = cursor.getLong(0)
                    cursor.close()
                    
                    val contentUri = ContentUris.withAppendedId(audioUri, id)
                    
                    try {
                        val deleted = contentResolver.delete(contentUri, null, null) > 0
                        if (deleted) {
                            // Also delete the physical file if it exists
                            if (file.exists()) {
                                file.delete()
                            }
                            return true
                        }
                    } catch (e: Exception) {
                        android.util.Log.e("DeleteFile", "ContentUri delete failed: ${e.message}")
                    }
                } else if (cursor != null) {
                    cursor.close()
                }
            } catch (e: Exception) {
                android.util.Log.e("DeleteFile", "MediaStore lookup failed: ${e.message}")
            }
            
            // Fallback: Try deleting directly from MediaStore using data path
            try {
                val deleted = contentResolver.delete(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    "${MediaStore.Audio.Media.DATA}=?",
                    arrayOf(path)
                ) > 0
                
                if (deleted && file.exists()) {
                    file.delete()
                }
                
                return deleted
            } catch (e: Exception) {
                android.util.Log.e("DeleteFile", "Data path delete failed: ${e.message}")
            }
            
            // Last resort: Try direct file deletion
            if (file.exists()) {
                file.delete()
            } else {
                false
            }
        } catch (e: Exception) {
            android.util.Log.e("DeleteFile", "All delete methods failed: ${e.message}")
            false
        }
    }
}

