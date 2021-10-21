package com.gongmanse.app.model

import java.io.Serializable


data class Model(

     val id: Int                        //동영상 ID
    ,val sTitle: String                 //동영상 제목
    ,val sSubject: String               //과목
    ,val sTeacher: String               //선생님 이름
    ,val sSubjectColor : String        //과목 배경색
    ,val sAvg: Double                   //별점
    ,val sThumbnail : String            //썸네일
    ,val iCount : Int?                   //시리즈 갯수


) : Serializable

