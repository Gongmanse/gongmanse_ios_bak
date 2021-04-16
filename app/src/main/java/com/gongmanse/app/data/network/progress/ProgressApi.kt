package com.gongmanse.app.data.network.progress

import com.gongmanse.app.data.model.progress.Progress
import com.gongmanse.app.data.model.progress.ProgressBody
import com.gongmanse.app.utils.Constants
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface ProgressApi {

    // 진도 탐색 리스트
    @GET("v3/progress/record/{${Constants.Request.KEY_SUBJECT}}")
    suspend fun getProgressList(
        @Path(Constants.Request.KEY_SUBJECT) subject: Int,
        @Query(Constants.Request.KEY_GRADE)  grade: String,
        @Query(Constants.Request.KEY_GRADE_NUM) gradeNum: Int,
        @Query(Constants.Request.KEY_OFFSET) offset: Int,
        @Query(Constants.Request.KEY_LIMIT) limit: Int
    ): Response<Progress>

}