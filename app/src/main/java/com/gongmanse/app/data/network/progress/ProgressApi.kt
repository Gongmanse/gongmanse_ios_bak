package com.gongmanse.app.data.network.progress

import com.gongmanse.app.utils.Constants
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface ProgressApi {

    /* 진도 탐색 리스트
    * Subject : 국영수(34), 과학(35), 사회(36), 기타(37)
    * Grade   : 모든, 초, 중, 고등
    * GradeNum: 0, 1, 2, 3, 4, 5, 6
    * */
    @GET("v3/progress/record/{subject}")
    fun getProgressList(
        @Path(Constants.Request.KEY_SUBJECT) subject: String,
        @Query(Constants.Request.KEY_OFFSET) offset: Int?,
        @Query(Constants.Request.KEY_LIMIT) limit: Int?,

    )




//    ?grade/gradeNum/offset/limit


}