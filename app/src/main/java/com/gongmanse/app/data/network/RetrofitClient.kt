package com.gongmanse.app.data.network

import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitClient {

    fun getService(): RetrofitService = retrofit.create(RetrofitService::class.java)

    private val gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss")
        .setLenient()
        .create()
    private val client: OkHttpClient = OkHttpClient.Builder()
        .addInterceptor(ResponseInterceptor())
//        .connectTimeout(1, TimeUnit.MINUTES)
//        .readTimeout(20, TimeUnit.SECONDS)
//        .writeTimeout(20, TimeUnit.SECONDS)
        .build()

    private val retrofit = Retrofit.Builder()
        .addConverterFactory(GsonConverterFactory.create(gson))
        .client(client)
        .build()

}