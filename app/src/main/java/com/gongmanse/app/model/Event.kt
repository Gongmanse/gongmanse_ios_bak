package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.Expose
import java.io.Serializable

data class Event (
    @SerializedName(Constants.RESPONSE_KEY_DATA)            val data: ObservableArrayList<EventData>?
) : BaseObservable(), Serializable

data class EventData(
    @SerializedName(Constants.RESPONSE_KEY_ID)              val id: String?,
    @SerializedName(Constants.RESPONSE_KEY_TITLE)           val title: String?,
    @SerializedName(Constants.RESPONSE_KEY_CREATE_DATE)     val date: String?,
    @SerializedName(Constants.RESPONSE_KEY_THUMBNAIL)       val thumbnail: String?,
    @SerializedName(Constants.RESPONSE_KEY_VIEWS)           val views: String?,
    @SerializedName(Constants.RESPONSE_KEY_TYPE)            val type: String?,
    @SerializedName(Constants.RESPONSE_KEY_STATUS)          val status: Boolean?,
    @SerializedName(Constants.RESPONSE_KEY_DESCRIPTION)     val content: String?
) : BaseObservable(), Serializable