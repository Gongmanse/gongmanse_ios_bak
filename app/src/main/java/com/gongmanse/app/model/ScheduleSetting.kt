package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class ScheduleSetting (
        @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<ScheduleSettingData>?
) : BaseObservable(),Serializable

data class ScheduleSettingData (
    @SerializedName(Constants.RESPONSE_KEY_CALENDAR_MY) val my: String?,
    @SerializedName(Constants.RESPONSE_KEY_CALENDAR_CEREMONY) val ceremony: String?,
    @SerializedName(Constants.RESPONSE_KEY_CALENDAR_EVENT) val event: String?

) : BaseObservable(),Serializable


