package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class Counsel (
        @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: String?,
        @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<CounselData>?
) : BaseObservable(),Serializable

data class CounselData (
    var itemType: Int,
    @SerializedName(Constants.RESPONSE_KEY_QUESTION) val sQuestion: String?,
    @SerializedName(Constants.RESPONSE_KEY_COUNSEL_ID) val consultation_id : String?,
    @SerializedName(Constants.RESPONSE_KEY_CU_ID) val cu_id : String?,
    @SerializedName(Constants.RESPONSE_KEY_NICKNAME) val sNickname: String?,
    @SerializedName(Constants.RESPONSE_KEY_ANSWER) val iAnswered: Int?,
    @SerializedName(Constants.RESPONSE_KEY_REGISTER_DATE) val dtRegister: String?,
    @SerializedName(Constants.RESPONSE_KEY_LAST_UPDATE) val dtLastUpdated: String?,
    @SerializedName(Constants.RESPONSE_KEY_ANSWER_CONTENT) val sAnswer: String?,
    @SerializedName(Constants.RESPONSE_KEY_PROFILE) val sProfile: String?,
    @SerializedName(Constants.RESPONSE_KEY_CONTENT_LIST_IMAGE) val filePath: String?,
    var isRemove: Boolean = false
) : BaseObservable(),Serializable {
    constructor() : this(0, null, null, null, null, null, null, null, null, null, null)
}
