package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import java.io.Serializable

data class User (
    @Expose @SerializedName(Constants.RESPONSE_KEY_SIMAGE) val sImage: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUSERNAME) val sUsername: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SFIRSENAME) val sFirstName: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SNICKNAME) val sNickname: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SEMAIL) val sEmail: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_STYPE) val eType: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_DTPREMIUMACTIVE) val dtPremiumActivate: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_DTPREMINUMEXPIRE) val dtPremiumExpire: String?
): BaseObservable(), Serializable

data class UserData (
    @Expose @SerializedName(Constants.RESPONSE_KEY_USER_ID) val userId: String?
): BaseObservable(), Serializable