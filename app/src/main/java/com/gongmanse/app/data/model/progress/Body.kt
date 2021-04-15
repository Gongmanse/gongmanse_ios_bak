package com.gongmanse.app.data.model.progress

data class Body(
    val grade: String,
    val gradeNum: String,
    val gradeNum2: String? = null,
    val gradeNum3: String? = null,
    val progressId: String,
    val subject: String,
    val subjectColor: String,
    val title: String,
    val totalCount: String
)