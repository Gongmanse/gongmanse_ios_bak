package com.gongmanse.app.data.model.teacher

import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.SerializedName

data class Teacher(
    @SerializedName(Constants.Response.KEY_BODY) val teacherBody: ArrayList<TeacherBody>,
    @SerializedName(Constants.Response.KEY_HEADER) val teacherHeader: TeacherHeader
)