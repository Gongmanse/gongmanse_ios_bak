package com.gongmanse.app.data.network.teacher

class TeacherRepository {

    private val teacherClient = TeacherService.client

    suspend fun getTeacher(grade : String?, offset : Int?, limit : Int?)
            = teacherClient.getTeacher(grade,offset,limit)

}
