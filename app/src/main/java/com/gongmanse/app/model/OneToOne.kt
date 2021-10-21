package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class OneToOne (
    @SerializedName(Constants.RESPONSE_KEY_DATA)          val data: ObservableArrayList<OneToOneData>
) : BaseObservable(), Serializable

data class OneToOneData(
    var itemType: Int,
    @SerializedName(Constants.RESPONSE_KEY_ID)            val id: Int = 0,
    @SerializedName(Constants.RESPONSE_KEY_ITYPE)         val type: String?,
    @SerializedName(Constants.RESPONSE_KEY_QUESTION)      val question: String?,
    @SerializedName(Constants.RESPONSE_KEY_QUESTION_DATE) val dt_question: String?,
    @SerializedName(Constants.RESPONSE_KEY_ANSWER_DATE)   val dt_answer: String?,
    @SerializedName(Constants.RESPONSE_KEY_ANSWER_STR)    val answer: String?,
    @SerializedName(Constants.RESPONSE_KEY_STATUS)        val status: Boolean = false
) : BaseObservable(), Serializable {
    constructor() : this(0, 0,null,null,null,null,null,false)
}