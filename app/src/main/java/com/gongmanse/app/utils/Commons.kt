package com.gongmanse.app.utils

import android.Manifest
import android.content.Context
import android.util.Log
import com.gongmanse.app.R
import com.gun0912.tedpermission.PermissionListener
import com.gun0912.tedpermission.TedPermission
import org.jetbrains.anko.alert

class Commons {
    companion object {

        private val TAG =  Commons::class.java.simpleName

        // Save Token
        fun saveToken(token: String) {
            Log.d(TAG, "saveToken => $token")
            Preferences.token = token
        }

        // Check Permission
        fun checkPermission(context: Context, permissionListener: PermissionListener) {
            TedPermission.with(context)
                .setPermissionListener(permissionListener)
                .setRationaleMessage(R.string.content_permission_request)
                .setDeniedMessage(R.string.content_permission_request_settings)
                .setPermissions(Manifest.permission.INTERNET, Manifest.permission.READ_PHONE_STATE)
                .check()
        }

        // Check Mobile Data
        fun checkMobileData(context: Context) {
            context.apply {
                context.apply {
                    alert (title = null, message = getString(R.string.content_using_mobile_data_when_play_the_video)){
                        positiveButton(getString(R.string.content_alert_positive_of_mobile_data)) {
                            it.dismiss()
                            Preferences.mobileData = true
                        }
                        negativeButton(getString(R.string.content_alert_negative_of_mobile_data)) {
                            it.dismiss()
                            Preferences.mobileData =  false
                        }
                    }.show()
                }
            }
        }

    }

    }
