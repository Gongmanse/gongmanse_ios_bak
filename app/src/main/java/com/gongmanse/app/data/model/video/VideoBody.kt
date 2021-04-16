package com.gongmanse.app.data.model.video

private var type: Int = 0
data class VideoBody(
    var viewType : Int,
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
    val totalRows : String?
)  {
    constructor() : this(type, null,
        null,null,null,
        null,null,null,null,
        null,null,null,null,null)

    companion object {
        fun setView(t: Int) {
            type = t
        }
    }
}