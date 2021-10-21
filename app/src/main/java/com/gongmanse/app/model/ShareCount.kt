package com.gongmanse.app.model

import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import java.io.Serializable

data class ShareCount(
    @SerializedName(Constants.RESPONSE_KEY_SHARE_COUNT) val countFiltered: Int,
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: List<ShareCountData>
): Serializable

data class ShareCountData(
    @Expose @SerializedName(Constants.RESPONSE_KEY_ID)              val id: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_USER_ID)         val userId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_VIDEO_ID)        val videoId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SHARE_TYPE)      val sType: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SHARE_DT)        val dtTimestamp: String,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SHARE_FIELD)     val sField: String,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SHARE_VALUE)     val sValue: String
): Serializable