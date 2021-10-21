package com.gongmanse.app.api.video

import com.gongmanse.app.model.*
import com.gongmanse.app.utils.Constants
import retrofit2.Response
import retrofit2.http.*

interface VideoApi {

    // 동영상 상세정보
    @GET("v/video/details")
    suspend fun getVideoData(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String?,
        @Query(Constants.REQUEST_KEY_VIDEO_ID) video_id: String?
    ): Response<Video?>

    // 추천 동영상 상세정보
    @GET("v/video/recommendurl")
    suspend fun getVideoData2(
        @Query(Constants.REQUEST_KEY_VIDEO_ID) video_id: String?
    ): Response<Video?>

    // 추천 동영상 상세정보
    @GET("v/video/recommendurl")
    suspend fun getVideoData2(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String?,
        @Query(Constants.REQUEST_KEY_VIDEO_ID) video_id: String?
    ): Response<Video?>

    // 동영상 강의 Q&A 내용
    @GET("v/video/detail_qna")
    suspend fun getQNAContents(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String?,
        @Query(Constants.REQUEST_KEY_VIDEO_ID) videoId: String?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int?,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int?
    ): Response<QNA?>

    // 동영상 강의 Q&A 추가
    @FormUrlEncoded
    @POST("v/video/detail_qna")
    suspend fun addQNAContents(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String?,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String?,
        @Field(Constants.RESPONSE_KEY_QNA_CONTENT) content: String?
    ): Response<Void>

    // 과목 리스트
    @GET("v/video/bycategory")
    suspend fun getSubjectList(
        @Query(Constants.REQUEST_KEY_CATEGORY_ID) category_id: Int,
        @Query(Constants.REQUEST_KEY_COMMENTARY) commentary : Int,
        @Query(Constants.REQUEST_KEY_SORT_ID) sort_id : Int?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int?,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int?
    ): Response<VideoList>

    // 진도학습 리스트
    @GET("/v/jindo/jindo_details")
    suspend fun getJindoDetail(
        @Query(Constants.REQUEST_KEY_JINDO_ID) jindo_id: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int?,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int?
    ): Response<VideoList>

    /* 검색 리스트 */
    // 동영상 백과
    @FormUrlEncoded
    @POST("/v/search/searchbar")
    suspend fun getSearchVideoList(
        @Field(Constants.REQUEST_KEY_SUBJECT) subject: Int?,
        @Field(Constants.REQUEST_KEY_GRADE) grade: String?,
        @Field(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Field(Constants.REQUEST_KEY_KEYWORD) keyword: String?,
        @Field(Constants.REQUEST_KEY_OFFSET)  offset: Int?,
        @Field(Constants.REQUEST_KEY_LIMIT)  limit: Int?
    ): Response<VideoList>


    // 강사별 리스트

    // 최근 영상 리스트
    @GET("v/member/watchhistory")
    suspend fun getRecentVideoList(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_SORT_ID) sorting: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int?,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int?
    ): Response<VideoList>

    // 북마크 리스트
    @GET("v/member/mybookmark")
    suspend fun getBookMarkList(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_SORT_ID) sorting: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int?,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int?
    ): Response<VideoList>

    // 관련 시리즈 리스트
    @GET("v/video/serieslist")
    suspend fun getSeriesList(
        @Query(Constants.REQUEST_KEY_SERIES_ID) seriesId: String?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int?,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int?
    ): Response<VideoList>

    // 관련 시리즈 POSITION
    @GET("v/video/rownum")
    suspend fun getSeriesNowPosition(
        @Query(Constants.REQUEST_KEY_SERIES_ID) seriesId: String?,
        @Query(Constants.REQUEST_KEY_VIDEO_ID) videoId: String?
    ): Response<Position>

    // 동영상 노트 정보
    @GET("v/video/detail_notes")
    suspend fun getNoteInfo(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.RESPONSE_KEY_VIDEO_ID) videoId: String?
    ): Response<NoteCanvas?>

    // 추천동영상 - 동영상 노트 정보
    @GET("v/video/recommendnotes")
    suspend fun getGuestNoteInfo(
        @Query(Constants.RESPONSE_KEY_VIDEO_ID) videoId: String?
    ): Response<NoteCanvasData?>

    // 동영상 노트 정보 업데이트
    @PATCH("v/video/detail_notes")
    @FormUrlEncoded
    suspend fun uploadNoteInfo(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String?,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String?,
        @Field(Constants.REQUEST_KEY_JSON) json: String?
    ): Response<Void>

    // 즐겨찾기 등록
    @POST("v/member/mybookmark")
    @FormUrlEncoded
    suspend fun addBookMark(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String?,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String?
    ): Response<Void>

    // 즐겨찾기 제거
    @PATCH("v/member/mybookmark")
    @FormUrlEncoded
    suspend fun removeBookMark(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String?,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String?
    ): Response<Void>

    // 평점 등록
    @POST("v/member/myrating")
    @FormUrlEncoded
    suspend fun addRating(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String?,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String?,
        @Field(Constants.REQUEST_KEY_RATING_VALUE) rating: Int?
    ): Response<Void>

    // 평점 제거
    @PATCH("v/member/myrating")
    @FormUrlEncoded
    suspend fun removeRating(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String?,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String?
    ): Response<Void>


}