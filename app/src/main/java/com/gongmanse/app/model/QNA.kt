package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class QNA (
    @Expose @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<QNAData>?
): BaseObservable(), Serializable

data class QNAData (
    var itemType: Int,
    @Expose @SerializedName(Constants.RESPONSE_KEY_ID)              val id: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_VIDEO_ID)        val videoId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SERIES_ID)       val seriesId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_THUMBNAIL)       val thumbnail: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUBJECT)         val subject: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUBJECT_COLOR)   val subjectColor: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TEACHER)         val teacherName: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TITLE)           val title: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_QUESTION)        val question: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_ANSWER)          val isAnswer: Int?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_LAST_UPDATE)     val dtUpdated: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_ANSWER_STR)      val answer: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_NICKNAME)        val nickname: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_USER_PROFILE)    val userProfile: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TEACHER_PROFILE) val teacherProfile: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_UNIT)            val unit: String?,
    var isRemove: Boolean = false
): BaseObservable(), Serializable {
    constructor() : this(0, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null)
}

data class QNADetail (
//    @Expose @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: Int = 0,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<QNADetailData>?
): BaseObservable(), Serializable

data class QNADetailData (
    var itemType: Int,
    @Expose @SerializedName(Constants.RESPONSE_KEY_QNA_ID)          val id: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_QUESTION)        val question: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_ANSWER_STR)      val answer: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_REGISTER_DATE)   val dtRegister: String?,
    var isRemove: Boolean = false
): BaseObservable(), Serializable {
    constructor() : this(Constants.VIEW_TYPE_ITEM, null, null, null, null, false)
}