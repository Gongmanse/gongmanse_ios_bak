package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import java.io.Serializable

data class Video (
    // 단일 항목
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATA) val data: VideoData?
): BaseObservable(), Serializable

data class VideoList (
    // 시리즈 정보
    @Expose @SerializedName(Constants.RESPONSE_KEY_SERIES) val seriesData: SeriesData?,
    // 전체 리스트 수
    @Expose @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: Int?,
    // 다음 목록 유무
    @Expose @SerializedName(Constants.RESPONSE_KEY_IS_MORE) val isMore: Boolean,
    // 리스트 목록
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<VideoData>?
): BaseObservable(), Serializable

data class SeriesData (
    @Expose @SerializedName(Constants.RESPONSE_KEY_TITLE)             val title: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TEACHER)           val teacherName: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUBJECT_COLOR)     val subjectColor: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUBJECT)           val subject: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_GRADE)             val grade: String?
): BaseObservable(), Serializable

data class VideoData (
    var itemType: Int,
    @Expose @SerializedName(Constants.RESPONSE_KEY_ID)              val id: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_USER_ID)         val userId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_VIDEO_ID)        val videoId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_CATEGORY_ID)     val categoryId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SERIES_ID)       val seriesId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_JINDO_ID)        val jindoId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_JINDOTITLE)      val jindoTitle: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_COMMENTARY_ID)   val commentaryId: String? = "0",
    @Expose @SerializedName(Constants.RESPONSE_KEY_BOOKMARK_ID)     val bookmarkId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TITLE)           val title: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TAGS)            val tags: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_HIGHLIGHT)       val highlight: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUBJECT)         val subject: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUBJECT_COLOR)   val subjectColor: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_KEYWORDS)        val keyword: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TEACHER)         val teacherName: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_THUMBNAIL)       val thumbnail: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_VIDEO_PATH)      val videoPath: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUBTITLE_PATH)   val subtitle: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_BOOKMARKS)       val bookmarks: Boolean,
    @Expose @SerializedName(Constants.RESPONSE_KEY_HAS_COMMENTARY)  val hasCommentary: Int = 0,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SERIES_COUNT)    val seriesCount: Int = 0,
    @Expose @SerializedName(Constants.RESPONSE_KEY_AVG)             val avg: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_RATING)          val rating: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_RATING_COUNT)    val ratingNum: Int = 0,
    @Expose @SerializedName(Constants.RESPONSE_KEY_RATE)            val rate: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_USER_RATE)       val userRate: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_REGISTER_DATE)   val dtRegister: String?,
    @Expose @SerializedName(Constants.BEST_TYPE)                    var viewType: String?,
    @Expose @SerializedName(Constants.REQUEST_KEY_SORT_ID)          var sortId: String?,
    @Expose @SerializedName(Constants.REQUEST_KEY_TEACHER_ID)       val instructorId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_LAST_UPDATE)     val dtUpdated: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_UNIT)            val unit: String = "",
    @Expose @SerializedName(Constants.RESPONSE_KEY_SOURCE_URL)      val videoURL: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_ACTIVE)          val iActive: String = "1",
    // 상태 변수
    var isFocusing: Boolean = false,
    var isRemove: Boolean = false
): BaseObservable(), Serializable {
    constructor() : this(0, null, null, null, null, null, null, null, "0", null, null, null, null, null, null, null, null, null, null, null, false, 0, 0, null, null, 0,null, null, null, null, null, null, null, "", null, "1")
}

data class VideoPlayer (
    @Expose @SerializedName(Constants.RESPONSE_KEY_ID)              val id: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_VIDEO_ID)        val videoId: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TITLE)           val title: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TEACHER)         val teacherName: String?,
    var videoURL: String?,
    var position: Long
): BaseObservable(), Serializable

data class Position (
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATA)            val data: PositionData?
): BaseObservable(), Serializable

data class PositionData (
    @Expose @SerializedName(Constants.RESPONSE_KEY_NUM)             val num : Int
): BaseObservable(), Serializable