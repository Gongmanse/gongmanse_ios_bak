package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import java.io.Serializable

data class Alarm(
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<AlarmData>?
): BaseObservable(), Serializable

data class AlarmData(
    var itemType: Int,
    @Expose @SerializedName(Constants.RESPONSE_KEY_ID) val id: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_STYPE) val eType: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_BODY) val sBody: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SDATA) val sData: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_PRIORITY) val sPriority: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TITLE) val sTitle: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_URI) val sUri: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_CREATE_DATE) val dtDateCreated: String?
): BaseObservable(), Serializable {
    constructor(): this(0, null, null, null, null,null, null, null, null)
}