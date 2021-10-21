package com.gongmanse.app.utils

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.gongmanse.app.R
import com.gongmanse.app.activities.MainActivity
import com.google.firebase.messaging.RemoteMessage

class FirebaseUtil {

    companion object {

        private val TAG = FirebaseUtil::class.java.simpleName

        /**
         * Register Notification Channel
         * */
        @RequiresApi(api = Build.VERSION_CODES.O)
        fun registerNotificationChannel(
            context: Context,
            id: String,
            name: String,
            description: String
        ) {
            val mNotificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel(id, name, importance)
            mChannel.apply {
                setDescription(description)
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
                vibrationPattern = longArrayOf(100, 200, 300, 400, 500, 400, 300, 200, 400)
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                setSound(
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION),
                    audioAttributes
                )
                mNotificationManager.createNotificationChannel(this)
            }
        }

        fun sendNotification(context: Context, title: String?, text: String?, deepLink: String?) {
            Log.d(TAG, "sendNotification => title => ${title}\n" + "message => ${text}\n" + " deepLink => $deepLink")

            val intent = Intent(context, MainActivity::class.java)
            intent.addCategory(Intent.CATEGORY_LAUNCHER)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
            intent.putExtra(Constants.EXTRA_KEY_DEEP_LINK, deepLink)

            val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    Constants.CHANNEL_ID,
                    Constants.CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = Constants.CHANNEL_DESCRIPTION
                    enableLights(true)
                    enableVibration(true)
                    setShowBadge(true)
                    vibrationPattern = longArrayOf(100, 200, 100, 200)
                }
                notificationManager.createNotificationChannel(channel)
            }

            val notificationBuilder = NotificationCompat.Builder(context, Constants.CHANNEL_ID).apply {
                setSmallIcon(R.mipmap.ic_icon_logo_round)
                title?.let { setContentTitle(it) }
                text?.let { setContentText(it) }
                setAutoCancel(true)
                setGroup(Constants.GROUP_ID)
                setDefaults(Notification.DEFAULT_SOUND or Notification.DEFAULT_VIBRATE)
                pendingIntent?.let { setContentIntent(it) }
            }

            notificationManager.notify(0, notificationBuilder.build())
        }
    }
}