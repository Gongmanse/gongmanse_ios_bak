package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.Expose
import java.io.Serializable

data class SettingInfo (
    @SerializedName(Constants.RESPONSE_KEY_GRADE)          val grade: String?,
    @SerializedName(Constants.RESPONSE_KEY_SETTING_SUB_ID) val subjectId: String?,
    @SerializedName(Constants.RESPONSE_KEY_NAME)           val subject: String?
): Serializable

data class Setting (
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATA)          val data: SettingData?
): BaseObservable(), Serializable

data class SettingData (
    @Expose @SerializedName(Constants.RESPONSE_KEY_GRADE)          val grade: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SETTING_SUB_ID) val subjectId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_NAME)           val subject: String?
): BaseObservable(), Serializable