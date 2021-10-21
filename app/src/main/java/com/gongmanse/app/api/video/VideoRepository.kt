package com.gongmanse.app.api.video

import android.util.Log
import com.gongmanse.app.model.VideoViewModel
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences

class VideoRepository {

    private val client = VideoService.client

    suspend fun getVideoData(videoId: String?) = client.getVideoData(Preferences.token, videoId)

    suspend fun getBestVideoData(videoId: String?) = if (Preferences.token.isEmpty()) client.getVideoData2(videoId) else client.getVideoData2(Preferences.token, videoId)

    suspend fun addQNAContents(videoId: String?, contents: String?) = client.addQNAContents(Preferences.token, videoId, contents)

    suspend fun getQNAContents(videoId: String?, offset: Int?) = client.getQNAContents(Preferences.token, videoId, offset, Constants.LIMIT_MAX_INT)

    suspend fun getNowPosition(seriesId: String?, videoId: String?) = client.getSeriesNowPosition(seriesId, videoId)

    suspend fun getPlayList(type: Int?, seriesId: String?, jindoId: Int?, sorting: Int?, subject: Int?, grade: String?, keyword: String?, offset: Int?, limit: Int?) = when (type) {
        // 국영수, 국영수-문제풀이
        Constants.QUERY_TYPE_KEM,
        Constants.QUERY_TYPE_KEM_PROBLEM -> client.getSubjectList(Constants.GRADE_SORT_ID_KEM, if (type == Constants.QUERY_TYPE_KEM) Constants.SUBJECT_COMMENTARY_ALL else Constants.SUBJECT_COMMENTARY_PROBLEM, sorting, offset, limit)
        // 과학, 과학-문제풀이
        Constants.QUERY_TYPE_SCIENCE,
        Constants.QUERY_TYPE_SCIENCE_PROBLEM -> client.getSubjectList(Constants.GRADE_SORT_ID_SCIENCE, if (type == Constants.QUERY_TYPE_SCIENCE) Constants.SUBJECT_COMMENTARY_ALL else Constants.SUBJECT_COMMENTARY_PROBLEM, sorting, offset, limit)
        // 사회, 사회-문제풀이
        Constants.QUERY_TYPE_SOCIETY,
        Constants.QUERY_TYPE_SOCIETY_PROBLEM -> client.getSubjectList(Constants.GRADE_SORT_ID_SOCIETY, if (type == Constants.QUERY_TYPE_SOCIETY) Constants.SUBJECT_COMMENTARY_ALL else Constants.SUBJECT_COMMENTARY_PROBLEM, sorting, offset, limit)
        // 기타, 기타-문제풀이
        Constants.QUERY_TYPE_ETC,
        Constants.QUERY_TYPE_ETC_PROBLEM -> client.getSubjectList(Constants.GRADE_SORT_ID_ETC, if (type == Constants.QUERY_TYPE_ETC) Constants.SUBJECT_COMMENTARY_ALL else Constants.SUBJECT_COMMENTARY_PROBLEM, sorting, offset, limit)
        // 진도 학습
        Constants.QUERY_TYPE_PROGRESS -> client.getJindoDetail(jindoId, offset, limit)
        // 검색
        Constants.QUERY_TYPE_SEARCH -> client.getSearchVideoList(subject, grade, sorting, keyword, offset, limit)
        // 강사별
        Constants.QUERY_TYPE_TEACHER -> client.getSeriesList(seriesId, offset, limit)
        // 최근 영상
        Constants.QUERY_TYPE_RECENT_VIDEO -> client.getRecentVideoList(Preferences.token, sorting, offset, limit)
        // 즐겨찾기
        Constants.QUERY_TYPE_FAVORITE -> client.getBookMarkList(Preferences.token, sorting, offset, limit)
        // 관련 시리즈
        Constants.QUERY_TYPE_SERIES -> client.getSeriesList(seriesId, offset, limit)
        // 예외
        else -> client.getSeriesList(seriesId, offset, limit)
    }

    suspend fun getNoteInfo(videoId: String?) = client.getNoteInfo(Preferences.token,videoId )

    suspend fun getGuestNoteInfo(videoId: String?) = client.getGuestNoteInfo(videoId)

    suspend fun uploadNoteInfo(videoId: String?,json : String) = client.uploadNoteInfo(Preferences.token, videoId,json)

    suspend fun addBookMark(videoId: String?) = client.addBookMark(Preferences.token, videoId)

    suspend fun removeBookMark(videoId: String?) = client.removeBookMark(Preferences.token, videoId)

    suspend fun getSeriesList(seriesId: String?,offset: Int?) = client.getSeriesList(seriesId,offset, Constants.LIMIT_DEFAULT_INT)

    suspend fun addRating(videoId: String?, rating: Int?) = client.addRating(Preferences.token, videoId, rating)

    suspend fun removeRating(videoId: String?) = client.removeRating(Preferences.token, videoId)

}