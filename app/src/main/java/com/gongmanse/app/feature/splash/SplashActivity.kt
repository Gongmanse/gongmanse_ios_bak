package com.gongmanse.app.feature.splash

import android.os.Bundle
import android.os.Handler
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.gongmanse.app.R
import com.gongmanse.app.data.network.member.MemberRepository
import com.gongmanse.app.feature.member.MemberViewModel
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import com.gun0912.tedpermission.PermissionListener
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class SplashActivity : AppCompatActivity() {

    companion object {
        private val TAG = SplashActivity::class.java.simpleName
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)
        Log.e(TAG, "onCreate Splash")
        nextPage()
//        Commons.checkPermission(this, permissionListener)
    }

    private var permissionListener: PermissionListener = object : PermissionListener {
        // 모든 권한을 허가 받았을 경우
        override fun onPermissionGranted() {
            if (Preferences.first) {
                Commons.checkMobileData(this@SplashActivity)
            }
            // 모든 권한 허가를 받지 못했을 경우
            else {
                nextPage()
            }
        }

        override fun onPermissionDenied(deniedPermissions: MutableList<String>?) {
            Log.d(TAG, "${deniedPermissions.toString()} ${R.string.content_toast_permission_denied}")
            nextPage()
        }
    }

    @Suppress("DEPRECATION")
    private fun nextPage() {
        Handler().postDelayed({
            finish()
        }, Constants.Delay.VALUE_OF_SPLASH)
    }
}