package com.gongmanse.app.data.model.video

import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.SerializedName

data class Video(
    @SerializedName(Constants.Response.KEY_BODY)   val videoBody: ArrayList<VideoBody>,
    @SerializedName(Constants.Response.KEY_HEADER) val videoHeader: VideoHeader


)