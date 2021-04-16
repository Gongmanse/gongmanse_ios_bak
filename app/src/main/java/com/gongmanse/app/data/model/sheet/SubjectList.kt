package com.gongmanse.app.data.model.sheet

import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.SerializedName

data class SubjectList(
    @SerializedName(Constants.Response.KEY_HEADER) val header: SubjectListHeader,
    @SerializedName(Constants.Response.KEY_BODY)   val subjectListBody: ArrayList<SubjectListBody>,
    var isCurrent: Boolean = false
)
