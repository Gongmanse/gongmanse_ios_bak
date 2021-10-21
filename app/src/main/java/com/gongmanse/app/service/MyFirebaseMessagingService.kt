package com.gongmanse.app.service

import android.net.Uri
import android.util.Log
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.model.UserData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.FirebaseUtil.Companion.sendNotification
import com.gongmanse.app.utils.Preferences
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*

class MyFirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private val TAG = MyFirebaseMessagingService::class.java.simpleName
    }

    override fun onCreate() {
        super.onCreate()
        FirebaseMessaging.getInstance().subscribeToTopic(Constants.TOPIC_TYPE_GLOBAL)
        FirebaseMessaging.getInstance().subscribeToTopic(Constants.TOPIC_TYPE_TEST)
//        FirebaseMessaging.getInstance().subscribeToTopic("event")
//        FirebaseMessaging.getInstance().subscribeToTopic("alarm_set")
    }

    // 토큰 발급
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.e(TAG, "Refreshed token => $token")
        Preferences.fcmToken = token
        sendRegistrationToServer(token)
    }

    // 토큰 정보 서버에 업데이트
    private fun sendRegistrationToServer(token: String) {
        Log.d(TAG, "sendRegistrationTokenToServer($token)")
        if (Preferences.token.isNotEmpty()) {
            RetrofitClient.getService().getUserId(Preferences.token).enqueue(object : Callback<UserData> {
                    override fun onFailure(call: Call<UserData>, t: Throwable) {
                        Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                    }

                    override fun onResponse(call: Call<UserData>, response: Response<UserData>) {
                        if (response.isSuccessful) {
                            Log.d(TAG, "response body => ${response.body()}")
                            response.body()?.userId?.let { sendTokenToServer(it, token) }
                        } else {
                            Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                        }
                    }
                })
        }
    }

    private fun sendTokenToServer(userId: String, token: String) {
        RetrofitClient.getService().registerFcmToken(token, userId, "Android").enqueue(object : Callback<ResponseBody> {
            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                if (response.isSuccessful) {
                    Log.d(TAG, "response body => ${response.body()}")
                } else {
                    Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                }
            }
        })
    }

    // 메시지 수신
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d(TAG, "onMessageReceived => $remoteMessage")
        Log.d(TAG, "isPushAlarm : ${Preferences.push}")
        Log.d(TAG, "remoteMessage => ${remoteMessage.data}")

        if (!Preferences.push) return

        val data = HashMap(remoteMessage.data)
        Log.d(TAG,"remoteMessage, title: ${remoteMessage.data["title"]}, body: ${remoteMessage.data["body"]}")

        if (remoteMessage.data.isNotEmpty()) {
            Log.d(TAG, "Message data payload: ${remoteMessage.data}")
                remoteMessage.data.apply {
                    Log.d(TAG,"remoteMessage.notification In")
                    when {
                        data.containsKey("deepLink") -> {
                            val deepLink = Uri.parse(data["deepLink"])
                            sendNotification(this@MyFirebaseMessagingService, data["title"], data["body"], data["deepLink"])
                            Log.v(TAG, "deepLink daw: $deepLink")
                        }

                        data.containsKey("purpose") -> {
                            Log.d(TAG, "containsKey: purpose")
                            handlePurpose(data["purpose"], data)
                        }

                        else -> {
                            Log.d(TAG, "containsKey: else")
                            sendNotification(this@MyFirebaseMessagingService, data["title"], data["body"], null)
                        }
                    }
                }
        }

    }

    private fun handlePurpose(purpose: String?, data: HashMap<String, String>) {
        Log.d(TAG, "handlePurpose()")
        when(purpose) {
            "alarm_set"    -> { Log.d(TAG, "alarm_set()") }
            "alarm_cancel" -> { Log.d(TAG, "alarm_cancel()") }
        }

    }


}

