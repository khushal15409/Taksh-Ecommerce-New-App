package com.example.taksh_e_commerce

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createPushChannel()
    }

    /**
     * The channel push notifications are shown on (Android 8+). It must exist before a push
     * arrives; the id matches the manifest's default_notification_channel_id and the server's
     * FCM_ANDROID_CHANNEL_ID.
     */
    private fun createPushChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        val channel = NotificationChannel(
            "taksh_orders",
            "Orders and payments",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Updates about your orders, payments and refunds"
        }
        manager.createNotificationChannel(channel)
    }
}
