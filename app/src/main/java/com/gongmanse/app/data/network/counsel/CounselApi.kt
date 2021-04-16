package com.gongmanse.app.data.network.counsel

import com.gongmanse.app.data.model.video.Video
import retrofit2.Response
import retrofit2.http.*

interface CounselApi {

    //긴급상담리스트
    @GET("v/v3/teacher/{grade}")
    suspend fun getSubject(
        @Path("grade") subject: String?,
        @Query("offset") offset: Int?,
        @Query("limit") limit: Int?
    ): Response<Video>

}