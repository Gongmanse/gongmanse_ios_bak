package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.Expose
import java.io.Serializable

data class Progress(
    @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: String?,
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<ProgressData>?
) : BaseObservable(), Serializable

data class ProgressData(
    var itemType: Int,
    @SerializedName(Constants.RESPONSE_KEY_ID)            val id: String?,
    @SerializedName(Constants.RESPONSE_KEY_JINDOTITLE)    var jindoTitle: String?,         // 타이틀
    @SerializedName(Constants.RESPONSE_KEY_FIRST_GRADE)   val grade1: String?,             // 학년
    @SerializedName(Constants.RESPONSE_KEY_SECOND_GRADE)  val grade2: String?,
    @SerializedName(Constants.RESPONSE_KEY_THIRD_GRADE)   val grade3: String?,
    @SerializedName(Constants.RESPONSE_KEY_GRADE)         val grade: String?,              // 학년 ()
    @SerializedName(Constants.RESPONSE_KEY_SUBJECT)       val subject: String?,            // 과목
    @SerializedName(Constants.RESPONSE_KEY_SUBJECT_COLOR) val subjectColor: String?,       // 과목 색상
    @SerializedName(Constants.RESPONSE_KEY_TOTAL_COUNT)   val totalCount: String?,         // 해당 강의 총 개수
    var isCurrent: Boolean = false
) : BaseObservable(), Serializable {
    constructor() : this(Constants.VIEW_TYPE_ITEM, null, null,null,null,null,null,null,null,null,false)
}


