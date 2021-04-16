package com.gongmanse.app.data.network.home

import com.gongmanse.app.data.model.video.Video
import retrofit2.Response
import retrofit2.http.*

interface VideoApi {

    //과목별 보기
    @GET("v3/video/subject/{subject}")
    suspend fun getSubject(
        @Path("subject") subject: Int?,
        @Query("offset") offset: Int?,
        @Query("limit") limit: Int?,
        @Query("sortId") sortId: Int?,
        @Query("type") type : Int?
    ): Response<Video>

    //배너
    @GET("v3/video/banner")
    suspend fun getBanner(
    ): Response<Video>

    //추천
    @GET("/v3/video/recommend/{grade}")
    suspend fun getBest(
        @Path("grade") subject: String?,
        @Query("offset") offset: Int?,
        @Query("limit") limit: Int?
    ): Response<Video>

    // 인기
    @GET("v3/video/trending/{grade}")
    suspend fun getHot(
        @Path("grade") subject: String?,
        @Query("offset") offset: Int?,
        @Query("limit") limit: Int?
    ): Response<Video>

}