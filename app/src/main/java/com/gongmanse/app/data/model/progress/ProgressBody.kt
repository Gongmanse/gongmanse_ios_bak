package com.gongmanse.app.data.model.progress

import com.gongmanse.app.utils.Constants
import java.io.Serializable

//private var type: Int = 0
data class ProgressBody(
    var viewType: Int,
    val grade: String?,
    val gradeNum: String?,
    val gradeNum2: String?,
    val gradeNum3: String?,
    val progressId: String?,
    val subject: String?,
    val subjectColor: String?,
    val title: String?,
    val totalRows: String?
) : Serializable {
    constructor() : this(
        Constants.ViewType.DEFAULT,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null
    )
}