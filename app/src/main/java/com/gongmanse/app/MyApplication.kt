package com.gongmanse.app

import android.app.Application
import android.util.Log
import com.bumptech.glide.Glide
import com.gongmanse.app.utils.Preferences

class MyApplication: Application() {

    companion object {
        private val TAG = MyApplication::class.java.simpleName
        var instance: MyApplication? = null
    }

    override fun onCreate() {
        super.onCreate()
        Preferences.init(this)
        instance = this
    }

    override fun onTerminate() {
        instance = null
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