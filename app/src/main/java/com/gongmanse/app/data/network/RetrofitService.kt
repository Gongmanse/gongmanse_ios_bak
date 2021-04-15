package com.gongmanse.app.data.network

import com.gongmanse.app.utils.Constants
import com.gongmanse.app.data.model.video.Video
import retrofit2.Call
import retrofit2.http.*

interface RetrofitService {

    // 토큰 재발급
    @FormUrlEncoded
    @POST("v1/auth/token")
    fun refreshToken(
        @Field(Constants.Request.KEY_GRANT_TYPE) grantType: String,
        @Field(Constants.Request.KEY_REFRESH_TOKEN) refreshToken: String
    ): Call<Map<String, String>>

    //과목별 보기
    @GET("v3/video/subject/{subject}")
    fun getSubject(
        @Path("subject") subject: Int?,
        @Query("offset") offset: Int?,
        @Query("limit") limit: Int?,
        @Query("sortId") sortId: Int?,
        @Query("type") type : Int?
    ): Call<Video>

    //배너
    @GET("v3/video/banner")
    fun getBanner(
    ): Call<Video>

    //추천
    @GET("/v3/video/recommend/{grade}")
    fun getBest(
        @Path("grade") subject: String?,
        @Query("offset") offset: Int?,
        @Query("limit") limit: Int?
    ): Call<Video>

    // 인기
    @GET("v3/video/trending/{grade}")
    fun getHot(
        @Path("grade") subject: String?,
        @Query("offset") offset: Int?,
        @Query("limit") limit: Int?
    ): Call<Video>

//    //과목별 보기
//    @GET("v3/video/recommend/{grade}")
//    fun getSubject(
//        @Path("subject") subject: Int?,
//        @Query("offset") offset: Int?,
//        @Query("limit") limit: Int?,
//        @Query("sortId") sortId: Int?
//    ): Call<Videos>


}

