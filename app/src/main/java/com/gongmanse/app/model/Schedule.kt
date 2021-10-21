package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class Schedule (
        @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<ScheduleData>?
) : BaseObservable(),Serializable

data class ScheduleData (
    @SerializedName(Constants.RESPONSE_KEY_CALENDAR_DATE) val date: String?,
    @SerializedName(Constants.RESPONSE_KEY_CALENDAR_DESCRIPTION) val description: ObservableArrayList<ScheduleDescription>?

) : BaseObservable(),Serializable

data class ScheduleDescription (

    @SerializedName(Constants.RESPONSE_KEY_ID) val calendarId: String?,
    @SerializedName(Constants.RESPONSE_KEY_TITLE) val title: String?,
    @SerializedName(Constants.RESPONSE_KEY_DESCRIPTION) val content : String?,
    @SerializedName(Constants.RESPONSE_KEY_WHOLE_DAY) val wholeDay : String?,
    @SerializedName(Constants.RESPONSE_KEY_LAST_START_DATE) val startDate: String,
    @SerializedName(Constants.RESPONSE_KEY_LAST_END_DATE) val endDate: String,
    @SerializedName(Constants.RESPONSE_KEY_ALARM_CODE) val alarmCode: String?,
    @SerializedName(Constants.RESPONSE_KEY_REPEAT_CODE) val repeatCode: String?,
    @SerializedName(Constants.RESPONSE_KEY_REPEAT_COUNT) val repeatCount: String?,
    @SerializedName(Constants.RESPONSE_KEY_REPEAT_RADIO) val repeatRadio: String?,
    @SerializedName(Constants.RESPONSE_KEY_TYPE) val type: String?
) : BaseObservable(),Serializable
