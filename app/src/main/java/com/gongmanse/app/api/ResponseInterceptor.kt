package com.gongmanse.app.api

import android.util.Log
import com.gongmanse.app.BuildConfig
import com.gongmanse.app.utils.GBLog
import okhttp3.Interceptor
import okhttp3.Response

class ResponseInterceptor: Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        return try {
            val response = chain.proceed(chain.request())
            if (BuildConfig.DEBUG)
                GBLog.v("", "$response")

            response.newBuilder()
                .addHeader("Content-Type", "application/json; charset=utf-8")
                .build()
        }catch (e : Exception){
            Log.e("ResponseInterceptor","$e")
            chain.proceed(chain.request())
        }

    }
}