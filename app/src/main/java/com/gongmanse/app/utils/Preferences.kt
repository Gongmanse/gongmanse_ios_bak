package com.gongmanse.app.utils

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit

object Preferences {

    private lateinit var prefs: SharedPreferences
    private const val FIRST_KEY               = "first"
    private const val TOKEN_KEY               = "token"
    private const val FCM_TOKEN_KEY           = "fcm_token"
    private const val REFRESH_KEY             = "refresh"
    private const val SUBTITLE_KEY            = "subtitle"
    private const val GRADE_KEY               = "grade"
    private const val SUBJECT_KEY             = "subject"
    private const val SUBJECT_ID_KEY          = "subjeId"
    private const val MOBILE_DATA_KEY         = "mobileData"
    private const val PUSH_KEY                = "push"
    private const val PUSH_SPECIALIST_KEY     = "specialist"
    private const val PUSH_ONE_ON_ONE_INQUIRY = "inquiry"
    private const val PUSH_MY_SCHEDULE_KEY    = "schedule"
    private const val PUSH_NOTICE_KEY         = "notice"
    private const val PLAY_LIST_POSITION      = "position"
    private const val SCHEDULE_MY             = "scheduleMy"
    private const val SCHEDULE_CEREMONY       = "scheduleCeremony"
    private const val SCHEDULE_EVENT          = "scheduleEvent"
    private const val PREMIUM_EXPIRE          = "expire"

    fun init(context: Context) {
        prefs = context.getSharedPreferences(context.packageName, Activity.MODE_PRIVATE)
    }

    var refresh: String
        get() = prefs.getString(REFRESH_KEY, "") ?: ""
        set(value) = prefs.edit {
            putString(REFRESH_KEY, value).apply()
        }

    var token: String
        get() = prefs.getString(TOKEN_KEY, "") ?: ""
        set(value) = prefs.edit {
            putString(TOKEN_KEY, value).apply()
        }

    var fcmToken: String
        get() = prefs.getString(FCM_TOKEN_KEY, "") ?: ""
        set(value) = prefs.edit {
            putString(FCM_TOKEN_KEY, value).apply()
        }

    var first: Boolean
        get() = prefs.getBoolean(FIRST_KEY, true)
        set(value) = prefs.edit {
            putBoolean(FIRST_KEY, value).apply()
        }

    var subtitle: Boolean
        get() = prefs.getBoolean(SUBTITLE_KEY, true)
        set(value) = prefs.edit {
            putBoolean(SUBTITLE_KEY, value).apply()
        }

    var grade: String
        get() = prefs.getString(GRADE_KEY, "") ?: ""
        set(value) = prefs.edit {
            putString(GRADE_KEY, value).apply()
        }

    var subject: String
        get() = prefs.getString(SUBJECT_KEY, "") ?: ""
        set(value) = prefs.edit {
            putString(SUBJECT_KEY, value).apply()
        }

    var subjectId: Int
        get() = prefs.getInt(SUBJECT_ID_KEY, 0)
        set(value) = prefs.edit {
            putInt(SUBJECT_ID_KEY, value).apply()
        }


    var mobileData: Boolean
        get() = prefs.getBoolean(MOBILE_DATA_KEY, true)
        set(value) = prefs.edit {
            putBoolean(MOBILE_DATA_KEY, value).apply()
        }

    var push: Boolean
        get() = prefs.getBoolean(PUSH_KEY, true)
        set(value) = prefs.edit {
            putBoolean(PUSH_KEY, value).apply()
        }

    var specialist: Boolean
        get() = prefs.getBoolean(PUSH_SPECIALIST_KEY, true)
        set(value) = prefs.edit {
            putBoolean(PUSH_SPECIALIST_KEY, value).apply()
        }

    var inquiry: Boolean
        get() = prefs.getBoolean(PUSH_ONE_ON_ONE_INQUIRY, true)
        set(value) = prefs.edit {
            putBoolean(PUSH_ONE_ON_ONE_INQUIRY, value).apply()
        }

    var schedule: Boolean
        get() = prefs.getBoolean(PUSH_MY_SCHEDULE_KEY, true)
        set(value) = prefs.edit {
            putBoolean(PUSH_MY_SCHEDULE_KEY, value).apply()
        }

    var notice: Boolean
        get() = prefs.getBoolean(PUSH_NOTICE_KEY, true)
        set(value) = prefs.edit {
            putBoolean(PUSH_NOTICE_KEY, value).apply()
        }

    var currentPosition: Int
        get() = prefs.getInt(PLAY_LIST_POSITION, 0)
        set(value) = prefs.edit {
            putInt(PLAY_LIST_POSITION, value).apply()
        }
    var scheduleMy: Int
        get() = prefs.getInt(SCHEDULE_MY, 1)
        set(value) = prefs.edit {
            putInt(SCHEDULE_MY, value).apply()
        }
    var scheduleCeremony: Int
        get() = prefs.getInt(SCHEDULE_CEREMONY, 1)
        set(value) = prefs.edit {
            putInt(SCHEDULE_CEREMONY, value).apply()
        }
    var scheduleEvent: Int
        get() = prefs.getInt(SCHEDULE_EVENT, 1)
        set(value) = prefs.edit {
            putInt(SCHEDULE_EVENT, value).apply()
        }

    var expire: String
        get() = prefs.getString(PREMIUM_EXPIRE, "") ?: ""
        set(value) = prefs.edit {
            putString(PREMIUM_EXPIRE, value).apply()
        }
}