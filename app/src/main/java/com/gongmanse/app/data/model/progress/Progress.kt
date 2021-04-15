package com.gongmanse.app.data.model.progress

import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.SerializedName

data class Progress(
    @SerializedName(Constants.Response.KEY_BODY)   val progressBody: ArrayList<ProgressBody>,
    @SerializedName(Constants.Response.KEY_HEADER) val progressHeader: ProgressHeader
)