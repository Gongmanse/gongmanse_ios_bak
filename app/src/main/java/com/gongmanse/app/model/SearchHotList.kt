package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class SearchHotList(
    @SerializedName(Constants.RESPONSE_KEY_LAST_UPDATE) val lastUpdate: String?,
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<SearchHotListData>?
) : BaseObservable(), Serializable

data class SearchHotListData(
    @SerializedName(Constants.RESPONSE_KEY_ID) val id: Int,
    @SerializedName(Constants.RESPONSE_KEY_KEYWORDS) val keyword: String
)


