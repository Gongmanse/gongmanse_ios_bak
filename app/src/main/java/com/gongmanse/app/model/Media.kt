package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class Media (
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: List<String>?
) : BaseObservable(), Serializable
