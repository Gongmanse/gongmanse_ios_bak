package com.gongmanse.app.feature.permission

import android.Manifest
import android.app.AlertDialog
import android.content.Context
import android.content.DialogInterface
import android.os.Build
import com.gongmanse.app.R

class checkPermission {

    companion object {

        const val checkPer: String = ""
        const val result: Boolean  = false

        fun checkPermissionDialog(context: Context) {
            // Version: 마시멜로우 이상
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // 필요한 Permission 선언
                val permissionList = mutableListOf<String>(
                    Manifest.permission.INTERNET,
                    Manifest.permission.READ_PHONE_STATE,
                    Manifest.permission.CAMERA,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    Manifest.permission.READ_EXTERNAL_STORAGE
                )

                val dialog: AlertDialog.Builder = AlertDialog.Builder(context)
                dialog.setTitle("권한이 필요합니다.")
                    .setMessage(R.string.content_permission_request)
                    .setPositiveButton(R.string.content_alert_positive_of_mobile_data
                    ) { dialog, which -> TODO("Not yet implemented")

                    }


            }
            // Version: 마시멜로우 미만, 즉시 실행
            else {
                // next Page()?
            }
        }

    }
}