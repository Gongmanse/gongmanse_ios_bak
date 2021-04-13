package com.gongmanse.app.data.network

import com.gongmanse.app.data.model.Video
import retrofit2.Call
import retrofit2.http.*

interface RetrofitService {

    // 토큰 재발급
    @FormUrlEncoded
    @POST("v1/auth/token")
    fun refresh(
//        @Field(Constants.REQUEST_KEY_GRANT_TYPE) grantType: String,
//        @Field(Constants.REQUEST_KEY_REFRESH) refreshToken: String
    ): Call<Map<String, String>>

    //과목별 보기
    @GET("v3/video/subject/{subject}")
    fun getSubject(
        @Path("subject") subject: Int?,
        @Query("offset") offset: Int?,
        @Query("limit") limit: Int?,
        @Query("sortId") sortId: Int?
    ): Call<Video>

    //배너
    @GET("/v3/video/banner")
    fun getSubject(): Call<Video>
//
//    //과목별 보기
//    @GET("v3/video/recommend/{grade}")
//    fun getSubject(
//        @Path("subject") subject: Int?,
//        @Query("offset") offset: Int?,
//        @Query("limit") limit: Int?,
//        @Query("sortId") sortId: Int?
//    ): Call<Videos>


}

