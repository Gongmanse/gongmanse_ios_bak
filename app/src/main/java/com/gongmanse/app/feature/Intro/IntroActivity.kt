package com.gongmanse.app.feature.Intro

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.R
import com.gongmanse.app.utils.Preferences
import com.gun0912.tedpermission.PermissionListener
import kotlinx.android.synthetic.main.activity_intro.*
import org.jetbrains.anko.toast
import kotlin.system.exitProcess

class IntroActivity : AppCompatActivity() {

    companion object {
        private val TAG = IntroActivity::class.java.simpleName
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_intro)
        Log.e(TAG, "onCreate to Intro")
        initView()
    }

    override fun onBackPressed() {
        ActivityCompat.finishAffinity(this)
        exitProcess(0)
    }

    private fun initView() {
        Commons.checkPermission(this, permissionListener)
        btn_intro_next.setOnClickListener {
            Preferences.first = false
            finish()
        }
    }

    private var permissionListener: PermissionListener = object : PermissionListener {
        override fun onPermissionGranted() {
            if (Preferences.first) Commons.checkMobileData(this@IntroActivity)
        }

        override fun onPermissionDenied(deniedPermissions: MutableList<String>?) {
            toast(R.string.content_toast_permission_denied)
        }
    }


}