package com.gongmanse.app.model

import java.io.Serializable


data class Test(
    val color : Int,            //배경
    val subject: String,                //과목
    val title: String,                  //동영상 제목
    val teacherName: String           //선생님 이름

) : Serializable
