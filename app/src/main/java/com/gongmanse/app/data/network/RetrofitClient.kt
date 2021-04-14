package com.gongmanse.app.data.network

import com.gongmanse.app.utils.Constants
import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitClient {

    // Base
    fun getService(): RetrofitService = retrofit.create(RetrofitService::class.java)
    // File
    fun getServiceFile(): RetrofitService = retrofitFile.create(RetrofitService::class.java)

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
        .baseUrl(Constants.BASE_DOMAIN)
        .addConverterFactory(GsonConverterFactory.create(gson))
        .client(client)
        .build()

    private val retrofitFile = Retrofit.Builder()
        .baseUrl(Constants.FILE_DOMAIN)
        .addConverterFactory(GsonConverterFactory.create(gson))
        .client(client)
        .build()



}