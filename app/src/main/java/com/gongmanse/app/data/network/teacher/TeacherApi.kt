package com.gongmanse.app.data.network.teacher

import com.gongmanse.app.data.model.teacher.Teacher
import retrofit2.Response
import retrofit2.http.*

interface TeacherApi {

    //선생님 리스트
    @GET("v3/teacher/{grade}")
    suspend fun getTeacher(
        @Path("grade") subject: String?,
        @Query("offset") offset: Int?,
        @Query("limit") limit: Int?
    ): Response<Teacher>

}