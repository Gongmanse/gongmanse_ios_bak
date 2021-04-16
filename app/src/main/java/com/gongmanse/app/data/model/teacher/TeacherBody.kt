package com.gongmanse.app.data.model.teacher

data class TeacherBody(
    var viewType : Int,
    val seriesId: String?,
    val teacherId: String?,
    val grade : String?,
    val subject: String?,
    val subjectColor: String?,
    val teacherName: String?,
    val thumbnail: String?,
    val title: String?,
    val totalRows: String?,
    val videoId: String?
){constructor() : this(0, null,
null,null,null,null,null,
null,null,null,null)}