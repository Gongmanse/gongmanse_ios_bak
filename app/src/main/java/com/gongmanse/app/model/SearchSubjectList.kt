package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class SearchSubjectList(
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<SearchSubjectListData>?
) : BaseObservable(), Serializable

data class SearchSubjectListData(
    @SerializedName(Constants.RESPONSE_KEY_ID) val id: Int?,
    @SerializedName(Constants.RESPONSE_KEY_NAME) val subject: String?,
    var isCurrent: Boolean = false
) : BaseObservable(), Serializable