package com.gongmanse.app

import android.app.Application
import android.content.Context
import android.util.Log
import androidx.appcompat.app.AppCompatDelegate
import com.bumptech.glide.Glide
import com.gongmanse.app.utils.Preferences

class MyApplication: Application() {

    companion object {
        lateinit var instance: MyApplication
        private val TAG = MyApplication::class.java.simpleName
    }

    override fun onCreate() {
        super.onCreate()
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)  //다크모드 안되도록
        Preferences.init(this)
//        KakaoSdk.init(this, getString(R.string.kakao_app_key)) // Kakao AppKey 초기화
        instance = this
    }

    fun getAppContext(): Context {
        return this.applicationContext
    }

    override fun onTerminate() {
        Log.v(TAG, "onTerminate...")
        super.onTerminate()
    }

    override fun onLowMemory() {
        super.onLowMemory()
        Log.v(TAG, "onLowMemory...")
        Glide.get(this).clearMemory()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        Log.v(TAG, "onTrimMemory...")
        Glide.get(this).trimMemory(level)
    }
}