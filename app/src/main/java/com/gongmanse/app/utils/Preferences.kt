package com.gongmanse.app.utils

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit

object Preferences {

    private lateinit var prefs: SharedPreferences
    private const val FIRST_KEY               = "first"
    private const val TOKEN_KEY               = "token"
    private const val REFRESH_KEY             = "refresh"
    private const val MOBILE_DATA_KEY         = "mobileData"

    fun init(context: Context) {
        prefs = context.getSharedPreferences(context.packageName, Activity.MODE_PRIVATE)
    }

    // 체크: 최초 실행 여부
    var first: Boolean
        get() = prefs.getBoolean(FIRST_KEY, true)
        set(value) = prefs.edit {
            putBoolean(FIRST_KEY, value).apply()
        }

    // 체크: 토큰
    var token: String
        get() = prefs.getString(TOKEN_KEY, "") ?: ""
        set(value) = prefs.edit {
            putString(TOKEN_KEY, value).apply()
        }

    // 체크: 모바일 데이터 헝용 여부
    var mobileData: Boolean
        get() = prefs.getBoolean(MOBILE_DATA_KEY, true)
        set(value) = prefs.edit {
            putBoolean(MOBILE_DATA_KEY, value).apply()
        }

    // 체크: Refresh Token
    var refresh: String
        get() = prefs.getString(REFRESH_KEY, "") ?: ""
        set(value) = prefs.edit {
            putString(REFRESH_KEY, value).apply()
        }
}