package com.gongmanse.app.model

import java.io.Serializable

data class VideoQuery(
    val isAutoPlay: Boolean = false, // 자동 재생 여부
    var queryType: Int = -1,
    var videoId: Int = 0,
    val jindoId: String? = null,
    var position: Int = 0,
    val sort_id: Int? = null,
    val keyword: String? = null, // 검색어
    val grade: String? = null,   // 학년
    val subject: Int? = 0,        // 과목
    val teacherId: Int = 0,      // 선생님 PK
    var seriesId: Int = 0,        // 시리즈 PK
    var autoPlay : Boolean = false, // 자동 재생
    var hashTag : String? = null, // 해시태그
    val tabPosition : Int = 0
):Serializable
