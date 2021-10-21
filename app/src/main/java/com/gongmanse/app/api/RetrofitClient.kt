package com.gongmanse.app.api

import com.gongmanse.app.utils.Constants
import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.net.ssl.X509TrustManager

object RetrofitClient {

    fun getService(): RetrofitService = retrofit.create(RetrofitService::class.java)
    fun getServiceFile(): RetrofitService = retrofit2.create(RetrofitService::class.java)
    fun getServiceHTML(): RetrofitService = retrofit3.create(RetrofitService::class.java)

    private val gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss")
        .setLenient()
        .create()
    private val client: OkHttpClient = OkHttpClient.Builder()
        .addInterceptor(ResponseInterceptor())
        .sslSocketFactory(
            SSLHelper.getInstance().sslContext.socketFactory,
            SSLHelper.getInstance().tmf.trustManagers[0] as X509TrustManager
        )
//        .connectTimeout(1, TimeUnit.MINUTES)
//        .readTimeout(20, TimeUnit.SECONDS)
//        .writeTimeout(20, TimeUnit.SECONDS)
        .build()

    private val retrofit = Retrofit.Builder()
        .baseUrl(Constants.BASE_DOMAIN)
        .addConverterFactory(GsonConverterFactory.create(gson))
        .client(client)
        .build()

    private val retrofit2 = Retrofit.Builder()
        .baseUrl(Constants.FILE_DOMAIN)
        .addConverterFactory(GsonConverterFactory.create(gson))
        .client(client)
        .build()

    private val retrofit3 = Retrofit.Builder()
        .baseUrl(Constants.BASE_DOMAIN)
        .client(client)
        .build()

    fun getClient(baseUrl: String): Retrofit = Retrofit.Builder()
        .baseUrl(baseUrl)
        .addConverterFactory(GsonConverterFactory.create(gson))
        .client(client)
        .build()

}