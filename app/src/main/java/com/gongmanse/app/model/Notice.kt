package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class Notice (
    @SerializedName(Constants.RESPONSE_KEY_DATA)            val data: ObservableArrayList<NoticeData>?
) : BaseObservable(), Serializable

data class NoticeData(
    @SerializedName(Constants.RESPONSE_KEY_ID)              val id: String?,
    @SerializedName(Constants.RESPONSE_KEY_TITLE)           val title: String?,
    @SerializedName(Constants.RESPONSE_KEY_CREATE_DATE)     val date: String?,
    @SerializedName(Constants.RESPONSE_KEY_CONTENT_IMAGE)   val contentImg: String?,
    @SerializedName(Constants.RESPONSE_KEY_VIEWS)           val views: String?,
    @SerializedName(Constants.RESPONSE_KEY_DESCRIPTION)     val content: String?
) : BaseObservable(), Serializable