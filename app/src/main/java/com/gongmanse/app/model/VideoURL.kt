package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.SerializedName
import java.io.Serializable

data class VideoURL (
    @SerializedName(Constants.RESPONSE_KEY_SOURCE_URL) val sourceUrl: String?,
    @SerializedName(Constants.RESPONSE_KEY_VIDEO_PATH) val videoPath: String?
): BaseObservable(), Serializable