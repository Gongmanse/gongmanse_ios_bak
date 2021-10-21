package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import java.io.Serializable

data class Purchase (
    @Expose @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<PurchaseData>?
) : BaseObservable(), Serializable

data class PurchaseData (
    var itemType: Int,
    @Expose @SerializedName(Constants.RESPONSE_KEY_DURATION) val duration: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_PAY_METHOD) val payMethod: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_PREMIUM_ACTIVE) val premiumActivate: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_PREMIUM_EXPIRE) val premiumExpire: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATE_INITIATE) val regDate: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_PRICE) val price: String?
) : BaseObservable(), Serializable {
    constructor() : this(0, null, null, null, null, null, null)
}