package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class SearchRecentList(
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<SearchRecentListData>?
) : BaseObservable(), Serializable

data class SearchRecentListData(
    @SerializedName(Constants.RESPONSE_KEY_ID) val id: String,
    @SerializedName(Constants.RESPONSE_KEY_WORDS) val keyword: String,
    @SerializedName(Constants.RESPONSE_KEY_CREATE_DATE) val created_date: String
) : BaseObservable(), Serializable