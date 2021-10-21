package com.gongmanse.app.api

import android.util.ArrayMap
import com.gongmanse.app.model.*
import com.gongmanse.app.utils.Constants
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.http.*

interface RetrofitService {

    // FCM TOKEN 등록
    @FormUrlEncoded
    @POST("v1/push_notification/mobile_devices")
    fun registerFcmToken(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_USER_ID) user_id: String,
        @Field(Constants.REQUEST_KEY_OS_TYPE) os_type: String
    ): Call<ResponseBody>

    // 사용자 아이디 검색
    @GET("v/member/userid")
    fun getUserId(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String
    ): Call<UserData>

    // 아이디 중복확인
    @FormUrlEncoded
    @POST("v/member/duplication_username")
    fun confirmIdDuplication(
        @Field("username") username: String
    ): Call<Map<String, String>>

    // 닉네임 중복확인
    @FormUrlEncoded
    @POST("v/member/duplication_nickname")
    fun confirmNicknameDuplication(
        @Field("nickname") username: String
    ): Call<Map<String, String>>

    // 로그인
    @FormUrlEncoded
    @POST("v1/auth/token")
    fun login(
        @Field(Constants.REQUEST_KEY_GRANT_TYPE) grantType: String,
        @Field("usr") username: String,
        @Field("pwd") password: String
    ): Call<Map<String, String>>

    // 토큰 재발급
    @FormUrlEncoded
    @POST("v1/auth/token")
    fun refresh(
        @Field(Constants.REQUEST_KEY_GRANT_TYPE) grantType: String,
        @Field(Constants.REQUEST_KEY_REFRESH) refreshToken: String
    ): Call<Map<String, String>>

    // 회원가입 인증번호
    @FormUrlEncoded
    @POST("v1/sms/verifications")
    fun verificationCode(
        @Field(Constants.REQUEST_KEY_PHONE_NUMBER) phoneNumber: String
    ): Call<Map<String, Any>>

    // 회원가입
    @FormUrlEncoded
    @POST("v1/members")
    fun register(
        @Field(Constants.REQUEST_KEY_USERNAME) username: String,
        @Field(Constants.REQUEST_KEY_PASSWORD) password: String,
        @Field(Constants.REQUEST_KEY_PASSWORD_CONFIRM) confirm_password: String,
        @Field(Constants.REQUEST_KEY_NAME) first_name: String,
        @Field(Constants.REQUEST_KEY_NICKNAME) nickname: String,
        @Field(Constants.REQUEST_KEY_PHONE_NUMBER) phone_number: String,
        @Field(Constants.REQUEST_KEY_VERIFICATION_CODE) verification_code: String,
        @Field(Constants.REQUEST_KEY_EMAIL) email: String
    ): Call<Map<String, Any>>

    // 프로필 정보 로드
    @GET("v/member/getuserinfo")
    fun getUserInfo(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String
    ): Call<User>

    // 계정 유무 확인
    @GET("v/member/check_member")
    fun findRegister(
        @Query("name") name: String?,
        @Query("phone") phone: String?,
        @Query("email") email: String?,
        @Query("id") id: String?,
    ): Call<Data>

    // 아이디/비밀번호 찾기 인증번호 요청
    @GET("v/member/recoverid")
    fun findRecoverId(
        @Query("receiver_type") type: String,
        @Query("receiver") receiver: String,
        @Query("name") name: String
    ): Call<Map<String, String>>

    // 아이디/비밀번호 찾기 인증번호 요청
    @FormUrlEncoded
    @PUT("v1/recovery")
    fun requestAuthNumber(
        @Field("receiver_type") type: String,
        @Field("receiver") receiver: String,
        @Field("name") name: String
    ): Call<Map<String, String>>

    // 아이디/비밀번호 찾기 인증번호 요청
    @FormUrlEncoded
    @PUT("v1/recovery")
    fun requestEmailAuthNumber(
        @Field("receiver_type") type: String,
        @Field("receiver") receiver: String,
        @Field("name") name: String
    ): Call<ResponseBody>

    // 비밀번호 업데이트(수정)
    @FormUrlEncoded
    @POST("v/member/updatepw")
    fun findRecoverPassword1(
        @Field(Constants.REQUEST_KEY_USERNAME) username: String,
        @Field(Constants.REQUEST_KEY_PASSWORD) password: String
    ): Call<ResponseBody>

    // 비밀번호 업데이트(수정)
    @FormUrlEncoded
    @PATCH("v/member/updatepw")
    fun findRecoverPassword(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_PASSWORD) password: String
    ): Call<ResponseBody>

    // 인기 동영상 목록
    @GET("v/video/trendingvid")
    fun hotVideoLoad(
        @Query("receiver_type") type: String,
        @Query("receiver") receiver: String,
        @Query("name") name: String
    ): Call<Map<String, String>>

    // 결제 내역 목록
    @GET("v/payment/purchasehistory")
    fun getPurchaseHistory(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<Purchase>

    // 내 노트 목록
    @GET("v/member/mynotes")
    fun getNoteList(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<VideoList>

    // 동영상 노트 정보
    @GET("v/video/detail_notes")
    fun getNoteInfo(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.RESPONSE_KEY_VIDEO_ID) videoId: String
    ): Call<NoteCanvas>

    // 추천동영상 - 동영상 노트 정보
    @GET("v/video/recommendnotes")
    fun getGuestNoteInfo(
        @Query(Constants.RESPONSE_KEY_VIDEO_ID) videoId: String
    ): Call<NoteCanvasData>

    // 동영상 노트 정보 업데이트
    @PATCH("v/video/detail_notes")
    @FormUrlEncoded
    fun uploadNoteInfo(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String,
        @Field(Constants.REQUEST_KEY_JSON) json: String
    ): Call<Void>

    // 내 강의 Q&A 목록
    @GET("v/member/myqna")
    fun getQNAList(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<QNA>

    // 내 질문하기 목록
    @GET("v/member/myconsultation")
    fun getQuestionList(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<Counsel>

    // 내 즐겨찾기 목록
    @GET("v/member/mybookmark")
    fun getFavoriteList(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<VideoList>

    // 내 즐겨찾기 목록
    @GET("v3/notice")
    fun getAlarmList(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<Alarm>

    // 진도 탐색: 전체 조회 (국영수, 과학, 사회, 기타과목)
    @GET("/v/jindo/jinlist")
    fun getJindoList(
        @Query(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Query(Constants.REQUEST_KEY_GRADE)   grade: String?,
        @Query(Constants.REQUEST_KEY_IGRADE)  igrade: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<Progress>

    // 진도 탐색: 세부 화면
    @GET("/v/jindo/jindo_details")
    fun getJindoDetail(
        @Query(Constants.REQUEST_KEY_JINDO_ID) jindo_id: Int,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: String
    ): Call<VideoList>

    // 진도 탐색: 단원 타이틀
    @GET("/v/jindo/jintitle")
    fun getJindoTitle(
        @Query(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Query(Constants.REQUEST_KEY_GRADE) grade: String?,
        @Query(Constants.REQUEST_KEY_IGRADE) igrade: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int?
    ): Call<Progress>

    // 진도 탐색: 단원 개별
    @GET("/v/jindo/singlejindo")
    fun getJindoSingle(
        @Query(Constants.REQUEST_KEY_JINDO_ID) jindo_id: Int
    ): Call<Progress>

    // 검색: 인기 리스트
    @GET("/v/video/trending_keyword")
    fun getHotSearchList():Call<SearchHotList>

    // 검색: 최근 검색어
    @GET("v/member/mysearches")
    fun getRecentSearchList(
        @Query("token") token: String,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: String?,
        @Query(Constants.REQUEST_KEY_LIMIT)  limit: String?
    ): Call<SearchRecentList>

    // 검색: 최근 검색어 저장
    @FormUrlEncoded
    @POST("/v1/searches")
    fun updateRecentKeyword(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_WORDS) words: String?
    ): Call<Map<String, Any>>

    // 검색: 최근 검색어 삭제
    @FormUrlEncoded
    @POST("/v/search/mysearches")
    fun deleteRecentKeyword(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_KEYWORD_ID) keyword_id: Int
    ): Call<Void>

    // 검색: 과목 리스트 (바텀 시트)
    @GET("/v/search/subjectnum")
    fun getSubjectNum(
        @Query(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int
    ) : Call<SearchSubjectList>

    // 검색 결과: 동영상 백과
    @FormUrlEncoded
    @POST("/v/search/searchbar")
    fun getSearchVideoList(
        @Field(Constants.REQUEST_KEY_SUBJECT) subject: Int?,
        @Field(Constants.REQUEST_KEY_GRADE) grade: String?,
        @Field(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Field(Constants.REQUEST_KEY_KEYWORD) keyword: String?,
        @Field(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Field(Constants.REQUEST_KEY_LIMIT)  limit: String?
    ): Call<VideoList>

    // 검색 결과: 상담하기
    @FormUrlEncoded
    @POST("/v/search/search_consultation")
    fun getSearchCounselList(
        @Field(Constants.REQUEST_KEY_KEYWORD) keyword: String?,
        @Field(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Field(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Field(Constants.REQUEST_KEY_LIMIT)   limit: String
    ): Call <Counsel>

    // 검색 결과: 노트검색
    @FormUrlEncoded
    @POST("/v/search/searchnotes")
    fun getSearchNoteList(
        @Field(Constants.REQUEST_KEY_SUBJECT) subject: Int?,
        @Field(Constants.REQUEST_KEY_GRADE) grade: String?,
        @Field(Constants.REQUEST_KEY_KEYWORD) keyword: String?,
        @Field(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Field(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Field(Constants.REQUEST_KEY_LIMIT)  limit: String?
    ): Call<VideoList>

    // 설정: 계정에 등록된 학년 및 과목 가져오기
    @GET("/v/setting/searchsetting")
    fun getSettingInfo(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String
    ): Call<Map<String, Any>>

    // 설정: 계정에 등록된 학년 및 과목 가져오기
    @GET("/v/setting/searchsetting")
    fun getSetting(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String
    ): Call<Setting>

    // 설정: 계정에 등록된 학년 및 과목 업데이트
    @FormUrlEncoded
    @POST("/v/setting/searchsetting")
    fun updateSettingInfo(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_GRADE) grade: String?,
        @Field(Constants.REQUEST_KEY_SUBJECT) subject: String?
    ): Call<Void>

    // 설정: 공지사항
    @GET("/v/setting/notice")
    fun getNoticeList(
        @Query(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<Notice>

    // 설정: 공지사항 - 이벤트
    @GET("/v/setting/settingevent")
    fun getNoticeEventList(
        @Query(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT)  limit: String?
    ): Call<Event>

    // 설정: 고객센터 - 자주 묻는 질문
    @GET("/v/setting/faqlist")
    fun getFAQList(): Call<FAQ>

    // 설정: 고객센터 - 1:1 문의 조회
    @GET("/v/setting/personalqna")
    fun getOneToOneList(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String
    ): Call<OneToOne>

    // 설정: 고객센터 - 1:1 문의 세부 내용 조회
    @GET("/v/setting/detailqna")
    fun getCustomerService(
        @Query(Constants.REQUEST_KEY_QNA_ID) qna_id: Int?
    ): Call<OneToOne>

    // 설정: 고객센터 - 1:1 문의 등록
    @FormUrlEncoded
    @POST("/v/setting/personalqna")
    fun registerQNA(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_QUESTION) question: String?,
        @Field(Constants.REQUEST_KEY_TYPE)  type:Int
    ): Call<Void>

    // 설정: 고객센터 - 1:1 문의 수정
    @FormUrlEncoded
    @PATCH("v/setting/personalqna")
    fun editQNA(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_ID) id: Int?,
        @Field(Constants.REQUEST_KEY_QUESTION)  question: String?,
        @Field(Constants.REQUEST_KEY_TYPE) type:Int
    ): Call<Void>

    // 설정: 고객센터 - 1:1 문의 삭제
    @FormUrlEncoded
    @POST("/v/setting/deleteqna")
    fun deleteMyQNA(
        @Field(Constants.REQUEST_KEY_ID) id: Int?
    ): Call<Void>

    // 홈 추천 리스트
//    @GET("/v/video/recommendvid")
    @GET("/v/video/recommendvid")
    fun getBestList(
        @Query(Constants.REQUEST_KEY_GRADE) grade: String?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int
    ): Call<VideoList>

//    // 홈 배너 리스트
//    @GET("/v/video/recommendvid")
//    fun getBannerList(
//        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int
//    ): Call<VideoList>

    // 나의 활동 최근 영상 목록
    @GET("v/member/watchhistory")
    fun getRecentVideoList(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_SORT_ID) sortId: String?,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int
    ): Call<VideoList>

    // 홈 배너 리스트
    @GET("/v/video/bannervid")
    fun getBannerList(
        @Query(Constants.REQUEST_KEY_LIMIT) limit: Int
    ): Call<VideoList>

    // 홈 인기 리스트
    @GET("/v/video/trendingvid")
    fun getHotList(
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int,
        @Query(Constants.REQUEST_KEY_GRADE) grade: String?
    ): Call<VideoList>

    // 홈 과목별 목록( 국영수, 사회, 과학, 기타 등등)
    @GET("v/video/bycategory")
    fun getSubjectList(
        @Query(Constants.REQUEST_KEY_CATEGORY_ID) category_id: Int,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int,
        @Query("commentary") commentary : Int,
        @Query("sort_id") sort_id : Int,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String?
    ): Call<VideoList>

    // 홈 과목별 목록( 국영수, 사회, 과학, 기타 등등)
    @GET("v/video/bycategory")
    fun getSubjectList(
        @Query(Constants.REQUEST_KEY_CATEGORY_ID) category_id: Int,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int,
        @Query("commentary") commentary : Int,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String?
    ): Call<VideoList>

    // 홈 노트보기 목록 ( 국영수, 사회, 과학, 기타 등등)
    @GET("v/video/notelist")
    fun getNoteList(
        @Query(Constants.REQUEST_KEY_CATEGORY_ID) category_id: Int,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int
    ): Call<VideoList>

    // 강사별 보기 목록
    @GET("v/video/byteacher")
    fun getTeacherList(
        @Query("grade") grade: String,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int
    ): Call<Map<String, Any>>

    // 강사별 보기 해당 강사 시리즈 목록
    @GET("v/video/byteacher_series")
    fun getTeacherSeriesList(
        @Query(Constants.REQUEST_KEY_TEACHER_ID) instructor_id: Int,
        @Query(Constants.REQUEST_KEY_GRADE) grade: String,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int
    ): Call<VideoList>

    // 홈 시리즈보기
    @GET("v/video/byseries")
    fun getSeries(
        @Query(Constants.REQUEST_KEY_CATEGORY_ID) category_id: Int,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int
    ): Call<VideoList>

    // 홈 시리즈 상세 리스트 보기
    @GET("/v/video/serieslist")
    fun getSeriesList(
        @Query(Constants.REQUEST_KEY_SERIES_ID) series_id: Int,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: Int,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String?
    ): Call<VideoList>

    // 동영상 상세정보
    @GET("v/video/details")
    fun getVideoInfo(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_VIDEO_ID) video_id: String
    ): Call<Video>

    // 추천 동영상 상세정보
    @GET("v/video/vidinfo")
    fun getVideoInfoBest(
        @Query(Constants.REQUEST_KEY_VIDEO_ID) video_id: String
    ): Call<Video>

    // 동영상 상세정보 - 추천 동영상
    @GET("v/video/vidinfo")
    fun getBestVideoInfo(
        @Query(Constants.REQUEST_KEY_VIDEO_ID) video_id: String
    ): Call<Video>

    // 동영상 소스 URL
    @GET("v1/videos/{id}")
    fun getVideoSourceUrl(
        @Path("id") video_id: String,
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_WITH) with: String
    ): Call<VideoURL>

    // 동영상 소스 URL - 추천 동영상
    @GET("v/video/recommendurl")
    fun getBestVideoSourceUrl(
        @Query(Constants.REQUEST_KEY_VIDEO_ID) video_id: String
    ): Call<Video>

    //상담하기(하단 네비게이션) 리스트
    @GET("v/consultation/conlist")
    fun getCounselList(
        @Query(Constants.REQUEST_KEY_SORT_ID) sort_id: Int?,
        @Query(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT)   limit: String
    ): Call<Counsel>

    //상담하기 불러오기
    @GET("/v/consultation/condetails")
    fun getCounselMedia(
        @Query(Constants.RESPONSE_KEY_COUNSEL_ID) consultation_id : String?
    ): Call<Media>

    //상담하기 (긴급상담) 파일 url 요청
    @Multipart
    @POST("transfer/consultations/upload")
    fun uploadMedia(
        @Part(Constants.REQUEST_KEY_TOKEN) token: RequestBody,
        @Part file: MultipartBody.Part
    ): Call<ResponseBody>


    //상담하기 업로드
    @FormUrlEncoded
    @POST("v1/my/expert/consultations_urgent")
    fun uploadCounsel(
        @Field("token") token: String,
        @Field("question") content: String,
        @Field("media[]") media1: String?,
        @Field("media[]") media2: String?,
        @Field("media[]") media3: String?
    ): Call<Map<String, Any>>

    // 동영상 강의 Q&A 내용
    @GET("v/video/detail_qna")
    fun getQNAContents(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_VIDEO_ID) videoId: String,
        @Query(Constants.REQUEST_KEY_OFFSET) offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<QNA>

    // 동영상 강의 Q&A 내용
//    @GET("v/video/detail_qna")
    @GET("v/member/detailqna")
    fun getQNADetailContents(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_VIDEO_ID) videoId: String,
        @Query(Constants.REQUEST_KEY_OFFSET)  offset: String,
        @Query(Constants.REQUEST_KEY_LIMIT) limit: String
    ): Call<QNADetail>

    // 동영상 강의 Q&A 추가
    @FormUrlEncoded
    @POST("v/video/detail_qna")
    fun addQNAContents(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String,
        @Field(Constants.RESPONSE_KEY_QNA_CONTENT) content: String
    ): Call<Void>

    // 동영상 즐겨찾기 추가
    @FormUrlEncoded
    @POST("v/member/mybookmark")
    fun addFavorite(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String
    ): Call<Void>

    // 동영상 즐겨찾기 제거
    @FormUrlEncoded
    @PATCH("v/member/mybookmark")
    fun delFavorite(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String
    ): Call<Void>

    // 동영상 평점 추가
    @FormUrlEncoded
    @POST("v/member/myrating")
    fun addRating(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String,
        @Field(Constants.REQUEST_KEY_RATING_VALUE) value: String
    ): Call<Void>

    // 동영상 평점 제거
    @FormUrlEncoded
    @PATCH("v/member/myrating")
    fun delRating(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_VIDEO_ID) videoId: String
    ): Call<Void>

    // 동영상 강의 평점 수
    @GET("v/member/myrating")
    fun getRatingCount(
        @Query(Constants.REQUEST_KEY_VIDEO_ID) videoId: String
    ): Call<Data>

    // 이미지 스트리밍
    @GET("{url}")
    @Streaming
    suspend fun downloadImage(
        @Path("url") url: String
    ): Call<ResponseBody>

    // 캘린더 각각 달별 일정 리스트
    @FormUrlEncoded
    @POST("v/calendar/mycalendar")
    fun getMyScheduleList(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field("date") date: String
    ): Call<Schedule>

    // 캘린더 각각 일별 일정 리스트
    @FormUrlEncoded
    @POST("v/calendar/bydate")
    fun getMyScheduleDetailList(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field("date") date: String
    ): Call<Schedule>

    //캘린더 설정 불러오기
    @GET("v/calendar/mycalendar")
    fun getScheduleSetting(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String
    ): Call<ScheduleSetting>

    //캘린더 설정 수정
    @FormUrlEncoded
    @PUT("v/calendar/mycalendar")
    fun putScheduleSetting(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_CALENDAR_MY) iShowMy: String,
        @Field(Constants.REQUEST_KEY_CALENDAR_CEREMONY) iShowCeremony: String,
        @Field(Constants.REQUEST_KEY_CALENDAR_EVENT) iShowEvent: String
    ): Call<ResponseBody>

    //캘린더 수정
    @FormUrlEncoded
    @PUT("v/calendar/modifycalendar")
    fun putSchedule(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_CALENDAR_MY) iShowMy: String,
        @Field(Constants.REQUEST_KEY_CALENDAR_CEREMONY) iShowCeremony: String,
        @Field(Constants.REQUEST_KEY_CALENDAR_EVENT) iShowEvent: String
    ): Call<ResponseBody>


    @FormUrlEncoded
    @POST("v1/my/calendar/events")
    fun uploadCalendar(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field("title") title : String?,
        @Field("content") content : String?,
        @Field("is_whole_day") is_whole_day : String?,
        @Field("start_date") start_date : String?,
        @Field("end_date") end_date : String?,
        @Field("alarm") alarm : String?,
        @Field("repeat") repeat : String?,
        @Field("repeat_count") repeat_count : String?,
        @Field("repeat_radio") repeat_radio : String?
    ): Call<ResponseBody>

    @FormUrlEncoded
    @POST("/v/calendar/editcalendar")
    fun uploadCalendar(
        @Field("id") calendarId: String,
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field("title") title : String?,
        @Field("content") content : String?,
        @Field("is_whole_day") is_whole_day : String?,
        @Field("start_date") start_date : String?,
        @Field("end_date") end_date : String?,
        @Field("alarm") alarm : String?,
        @Field("repeat") repeat : String?,
        @Field("repeat_count") repeat_count : String?,
        @Field("repeat_radio") repeat_radio : String?
    ): Call<ResponseBody>

    @FormUrlEncoded
    @POST("/v/calendar/modifycalendar")
    fun deleteCalendar(
        @Field("id") calendarId: String
    ): Call<ResponseBody>


    // 프로필 이미지 업로드
    @Multipart
    @POST("transfer/profiles/image_upload")
    fun uploadProfileImage(
        @Part(Constants.REQUEST_KEY_TOKEN) token: RequestBody,
        @Part file: MultipartBody.Part
    ): Call<ResponseBody>

    // 프로필 정보 업로드
    @FormUrlEncoded
    @PATCH("v/member/getuserinfo")
    fun uploadProfileInfo(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_NICKNAME) nickname: String,
        @Field(Constants.REQUEST_KEY_EMAIL) email: String
    ): Call<ResponseBody>

    // 최근 영상 삭제
    @FormUrlEncoded
    @POST("v/member/watchhistory")
    fun removeRecentItem(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_HISTORY_ID) history_id: String
    ): Call<ResponseBody>

    // 즐겨찾기 삭제
    @FormUrlEncoded
    @PUT("v/member/mybookmark")
    fun removeFavorite(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_BOOKMARK_ID) bookmark_id: String
    ): Call<ResponseBody>

    // 노트 삭제
    @FormUrlEncoded
    @POST("v/member/mynotes")
    fun removeNote(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_NOTE_ID) note_id: String
    ): Call<ResponseBody>

    // 강의 Q&A 삭제
    @FormUrlEncoded
    @POST("v/member/myqna")
    fun removeQNA(
        @Field(Constants.REQUEST_KEY_QNA_ID) qna_id: String
    ): Call<ResponseBody>

    // 전문가 상담 삭제
    @FormUrlEncoded
    @POST("v/member/myconsultation")
    fun removeCounsel(
        @Field("con_id") con_id: String
    ): Call<ResponseBody>

    // 공유 URL
    @GET("v/video/sharekey")
    fun getShareURL(
        @Query(Constants.REQUEST_KEY_VIDEO_ID) videoId: String
    ): Call<Share>

    // 공유 URL 횟수 체크
    @GET("v1/my/video/statistics")
    fun getShareCount(
        @Query(Constants.REQUEST_KEY_TOKEN) token: String,
        @Query(Constants.REQUEST_KEY_FOR_TODAY) for_today: Int,
        @Query(Constants.REQUEST_KEY_FIELD) target: String,
        @Query(Constants.REQUEST_KEY_SHARE) value: String
    ): Call<ShareCount>

    // 공유 URL 횟수 업데이트
    @FormUrlEncoded
    @POST("v1/my/video/statistics")
    fun updateShareCount(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_VIDEO) video: String,
        @Field(Constants.REQUEST_KEY_FIELD_VALUE) field: String,
        @Field(Constants.REQUEST_KEY_SHARE_SOCIAL_TYPE) value: String
    ): Call<ResponseBody>

    @FormUrlEncoded
    @POST("v2/purchase")
    fun puchaseInApp(
        @Field(Constants.REQUEST_KEY_TOKEN) token: String,
        @Field(Constants.REQUEST_KEY_PURCHASE_TOKEN) purchaseToken: String,
        @Field(Constants.REQUEST_KEY_SKU) sku: String,
        @Field(Constants.REQUEST_KEY_ORDER_ID) orderId: String
    ): Call<ResponseBody>

}