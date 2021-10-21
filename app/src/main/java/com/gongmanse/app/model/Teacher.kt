package com.gongmanse.app.model

import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class Teacher(
    @SerializedName(Constants.RESPONSE_KEY_ID)            val id: Int,
    @SerializedName(Constants.RESPONSE_KEY_TITLE)         val title: String,
    @SerializedName(Constants.RESPONSE_KEY_GRADE)         val grade: String,
    @SerializedName(Constants.RESPONSE_KEY_TEACHER)       val teacherName: String,
    @SerializedName(Constants.RESPONSE_KEY_SUBJECT)       val subject: String,
    @SerializedName(Constants.RESPONSE_KEY_SUBJECT_COLOR) val subjectColor: String,
    @SerializedName(Constants.RESPONSE_KEY_THUMBNAIL)     val thumbnail: String
//    @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM)     val totalNum: String

/*
     val sName: String           // 선생님 이름
    ,val sThumbnail: String     // 썸네일
    ,val countNum: String        // 영상 개수
    ,val sGrade: String           // 학년(초,중,고)
    ,val id : Int,               // 동영상 id*/
// title        영상 제목
// subject      과목
// subjectColor 과목 색상
) : Serializable