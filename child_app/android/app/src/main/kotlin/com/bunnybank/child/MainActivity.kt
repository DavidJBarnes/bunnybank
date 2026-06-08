package com.bunnybank.child

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createChaChingChannel()
    }

    // High-importance channel whose sound is the authentic cash-register "cha-ching".
    // FCM background/closed-app notifications target this channel (see the
    // default_notification_channel_id meta-data in AndroidManifest), so the sound
    // plays even when the app isn't running.
    private fun createChaChingChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val soundUri = Uri.parse("android.resource://$packageName/raw/cha_ching")
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build()
            val channel = NotificationChannel(
                "cha_ching",
                "Money received",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Plays the cha-ching when you receive Bunny Bucks"
                setSound(soundUri, audioAttributes)
                enableVibration(true)
                enableLights(true)
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }
}
