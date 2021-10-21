package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class FAQ (
    @SerializedName(Constants.RESPONSE_KEY_DATA)         val data: ObservableArrayList<FAQData>
) : BaseObservable(), Serializable

data class FAQData(
    @SerializedName(Constants.RESPONSE_KEY_ID)           val id: Int,
    @SerializedName(Constants.RESPONSE_KEY_QUESTION)     val question: String,
    @SerializedName(Constants.RESPONSE_KEY_ANSWER_STR)   val answer: String,
    var isExpanded: Boolean = false
) : BaseObservable(), Serializable