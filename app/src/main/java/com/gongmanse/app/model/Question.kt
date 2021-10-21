package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class Question (
    @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: String?,
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<QuestionData>?
): BaseObservable(), Serializable

data class QuestionData (
    var itemType: Int,
    @SerializedName(Constants.RESPONSE_KEY_ID) val id: String?,
    @SerializedName(Constants.RESPONSE_KEY_QUESTION) val question: String?,
    @SerializedName(Constants.RESPONSE_KEY_NICKNAME) val nickname: String?,
    @SerializedName(Constants.RESPONSE_KEY_PROFILE) val avatar: String?,
    @SerializedName(Constants.RESPONSE_KEY_ANSWER) val isAnswer: Int?,
    @SerializedName(Constants.RESPONSE_KEY_LAST_UPDATE) val dtUpdated: String?,
    var isRemove: Boolean = false
): BaseObservable(), Serializable {
    constructor() : this(0, null, null, null, null, null, null)
}