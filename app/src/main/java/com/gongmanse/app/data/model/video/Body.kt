package com.gongmanse.app.data.model.video

data class Body(
    var itemType : Int = 0,
    val isRecommended: String?,
    val modifiedDate: String?,
    val rating: String?,
    val registrationDate: String?,
    val subject: String?,
    val subjectColor: String?,
    val tags: String?,
    val teacherName: String?,
    val thumbnail: String?,
    val title: String?,
    val unit: String?,
    val videoId: String?,
    val seriesCount : Int?
)