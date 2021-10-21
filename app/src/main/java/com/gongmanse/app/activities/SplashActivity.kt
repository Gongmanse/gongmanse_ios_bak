package com.gongmanse.app.activities

import android.app.Activity
import android.content.Intent
import android.content.IntentSender
import android.os.Bundle
import android.os.Handler
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.GBLog
import com.gongmanse.app.utils.PermissionUser
import com.gongmanse.app.utils.Preferences
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.install.InstallState
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.ActivityResult
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class SplashActivity : AppCompatActivity() {

    companion object {
        private val TAG = SplashActivity::class.java.simpleName
        private const val REQUEST_CODE_UPDATE = 1111
        private const val delayTime = 1500L // 1.5초
    }

    private var mPackageName: String? = null
    private var mAppUpdateManager: AppUpdateManager? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)
        if (Preferences.refresh.isNotEmpty()) getRefreshToken()
        mPackageName = packageName
        playStoreVersionCheck()
//        next()
        Log.d(TAG, "최초실행 => ${Preferences.first}")
        Log.d(TAG, "Firebase 토큰 => ${Preferences.fcmToken}")
    }

    override fun onResume() {
        super.onResume()
        mAppUpdateManager?.appUpdateInfo?.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                try {
                    mAppUpdateManager?.startUpdateFlowForResult(appUpdateInfo, AppUpdateType.FLEXIBLE, this, REQUEST_CODE_UPDATE)
                } catch (e: IntentSender.SendIntentException) {
                    e.printStackTrace()
                }
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun next() {
        Handler().postDelayed({
            finish()
        }, delayTime)
    }

    private fun getRefreshToken() {
        RetrofitClient.getService().refresh(Constants.REQUEST_KEY_GRANT_REFRESH, Preferences.refresh).enqueue(object : Callback<Map<String, String>> {
            override fun onFailure(call: Call<Map<String, String>>, t: Throwable) {
                GBLog.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, String>>, response: Response<Map<String, String>>) {
                if (response.isSuccessful) {
                    response.body()?.apply {
                        GBLog.d(TAG, "onResponse => ${this["token"]}")
                        Preferences.token = this[Constants.EXTRA_KEY_TOKEN].toString()
                    }
                } else {
                    GBLog.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                    toast(Constants.TOAST_MESSAGE_LOGIN)
                }
            }
        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_UPDATE) {
            when {
                resultCode == Activity.RESULT_CANCELED -> { // 사용자가 업데이트를 거부하거나 취소
                    Log.d("AppUpdate", "Update Failed or Canceled!")
                }
                requestCode == Activity.RESULT_OK -> { // 사용자가 업데이트를 수락
                    Log.d("AppUpdate", "Update Complete!")
                }
                resultCode == ActivityResult.RESULT_IN_APP_UPDATE_FAILED -> {
                    Log.d("AppUpdate", "Update flow failed! Result code: $resultCode")
                }
            }
            next()
        }
    }

    private fun playStoreVersionCheck() {
        mAppUpdateManager = AppUpdateManagerFactory.create(applicationContext)
        val appUpdateInfoTask = mAppUpdateManager?.appUpdateInfo
        appUpdateInfoTask?.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE && appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE)) {
                GBLog.d(TAG, "업데이트 있음")
                try {
                    mAppUpdateManager?.startUpdateFlowForResult(
                        appUpdateInfo,
                        AppUpdateType.FLEXIBLE,
                        this,
                        REQUEST_CODE_UPDATE
                    )
                } catch (e: IntentSender.SendIntentException) {
                    e.printStackTrace()
                }
            } else {
                GBLog.d(TAG, "업데이트 없음")
                next()
            }
        }

        val listener = object: InstallStateUpdatedListener {
            override fun onStateUpdate(state: InstallState) {
                if (state.installStatus() == InstallStatus.DOWNLOADED) {
                    if (mAppUpdateManager != null) mAppUpdateManager?.completeUpdate()
                } else if (state.installStatus() == InstallStatus.INSTALLED) {
                    if (mAppUpdateManager != null) mAppUpdateManager?.unregisterListener(this)
                    else Log.d(TAG, "InstallStateUpdatedListener: state: ${state.installStatus()}")
                }
            }
        }

        mAppUpdateManager?.registerListener(listener)
    }
}