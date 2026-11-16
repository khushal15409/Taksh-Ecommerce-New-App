package com.example.taksh_e_commerce

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentResolver
import android.media.AudioAttributes
import android.net.Uri
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
     * arrives; the id (taksh_orders_v5) matches the manifest's default_notification_channel_id and the server's
     * FCM_ANDROID_CHANNEL_ID.
     */
    private fun createPushChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        // Channel sound cannot be changed once a channel exists, so the custom
        // sound lives on a new id (v5) and the legacy channel is removed.
        manager.deleteNotificationChannel("taksh_orders")
        manager.deleteNotificationChannel("taksh_orders_v2")
        manager.deleteNotificationChannel("taksh_orders_v3")
        manager.deleteNotificationChannel("taksh_orders_v4")
        val soundUri = Uri.parse(
            "${ContentResolver.SCHEME_ANDROID_RESOURCE}://$packageName/raw/taksh_ding"
        )
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val channel = NotificationChannel(
            "taksh_orders_v5",
            "Orders and payments",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Updates about your orders, payments and refunds"
            enableLights(true)
            lightColor = 0xFFFFA340.toInt()
            enableVibration(true)
            setShowBadge(true)
            setSound(soundUri, audioAttributes)
        }
        manager.createNotificationChannel(channel)
    }
}
