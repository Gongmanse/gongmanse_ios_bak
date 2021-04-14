package com.gongmanse.app.feature.permission

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.gongmanse.app.R

class PermissionActivity : AppCompatActivity() {

    companion object {
        private val TAG = PermissionActivity::class.java.simpleName
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_permission)


    }
}