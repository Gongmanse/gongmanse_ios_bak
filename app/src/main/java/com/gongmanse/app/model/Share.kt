package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class Share (
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ShareData?
): BaseObservable(), Serializable

data class ShareData (
    @SerializedName(Constants.RESPONSE_KEY_SHARE_URL) val shareUrl: String?
): BaseObservable(), Serializable