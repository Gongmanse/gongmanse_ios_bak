package com.gongmanse.app.utils

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import android.util.TypedValue
import android.webkit.WebView
import android.widget.Toast
import com.gongmanse.app.activities.NoticeDetailWebViewActivity
import com.gongmanse.app.activities.SearchResultActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.activities.customer.CustomerServiceDetailActivity
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.model.EventData
import com.gongmanse.app.model.NoticeData
import com.gongmanse.app.model.OneToOneData
import com.gongmanse.app.model.User
import org.koin.core.logger.KOIN_TAG
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.io.BufferedInputStream
import java.io.IOException
import java.net.URL
import javax.net.ssl.HttpsURLConnection

class Constants {

    companion object {

        /* Server API IP */
        const val BASE_DOMAIN                    = "https://api.gongmanse.com"
        const val FILE_DOMAIN                    = "https://file.gongmanse.com"
        const val WEB_VIEW_DOMAIN                = "https://webview.gongmanse.com"
        const val NOTICE_EVENT_VALUE_DOMAIN      = "https://webview.gongmanse.com/events/view/"

        // 21.10.20 settings Dev domain
//        const val BASE_DOMAIN                    = "https://apidev.gongmanse.com"
//        const val FILE_DOMAIN                    = "https://filedev.gongmanse.com"
//        const val WEB_VIEW_DOMAIN                = "https://webviewdev.gongmanse.com"
//        const val NOTICE_EVENT_VALUE_DOMAIN      = "https://webviewdev.gongmanse.com/events/view/"

        const val PRIVACY_POLICY_DOMAIN          = "/users/privacy_policy"
        const val TERMS_OF_SERVICE_DOMAIN        = "/users/toa_read"

        /* Endless Delay Value */
        const val ENDLESS_DELAY_VALUE            = 0L
        const val BOTTOM_MOVE_DELAY              = 1000L

        /* Firebase Message Topic */
        const val TOPIC_TYPE_GLOBAL              = "global"
        const val TOPIC_TYPE_TEST                = "test"

        /* Video Activity Tab Index */
        const val NOTE_TAB                       = 0
        const val QNA_TAB                        = 1
        const val VIDEO_LIST_TAB                 = 2

        /* Result Code */
        const val SEARCH_RESULT_CODE             = 1000
        const val RELATION_RESULT_CODE           = 2000

        /* Notification */
        const val CHANNEL_ID                       = "채널"
        const val CHANNEL_NAME                     = "채널명"
        const val CHANNEL_DESCRIPTION              = "채널에 대한 설명"
        const val GROUP_ID                         = "com.gongmanse.app"
        const val FCM_TITLE                        = "title"
        const val FCM_BODY                         = "body"
        const val FCM_NOTIFICATION                 = "notification"
        const val FCM_DATA                         = "data"
        const val FCM_TO                           = "to"
        const val API_MY_NOTIFICATIONS             = "$BASE_DOMAIN/v1/my/push_notification/messages?"

        /*Calendar Start End Value*/
        const val START_TIME                    = 1
        const val END_TIME                      = 0
        const val DAY_OF_MONTH                  = 0
        const val WEEK_OF_MONTH                 = 1
        const val MONTH_DAY                     = 0
        const val MONTH_WEEK_OF_DAY             = 1
        const val VALUE_WHOLE_DAY               = "하루종일"


        /*Live Current Postion*/
        const val LIVE_DATA_DEFAULT_VALUE       = -1

        /* Canvas */
        const val MODE_PEN                       = 1
        const val MODE_ERASER                    = 2
        const val ASPECT_RATIO                   = "0.5095108695652174"
        const val STROKE_CAP                     = "round"
        const val STROKE_JOIN                    = "round"
        const val COLOR_TRANSPARENT              = "transparent"
        const val COLOR_RED                      = "#d82579"
        const val COLOR_GREEN                    = "#a7c645"
        const val COLOR_BLUE                     = "#29b3df"
        const val MITER_LIMIT                    = 10

        /* Video */
        const val VIDEO_INTRO                    = 0
        const val VIDEO_PLAY                     = 1
        const val VIDEO_OUTRO                    = 2
        const val KEY_PLAY_VIDEO                 = "playVideo"
        const val INSTANCE_KEY_PLAY_VIDEO        = "playVideo"
        const val INSTANCE_KEY_PLAY_STATE        = "playState"
        const val INSTANCE_KEY_PLAY_SPEED        = "playSpeed"
        const val INSTANCE_KEY_PLAY_POSITION     = "playPosition"
        const val INSTANCE_KEY_PLAY_FULL_SCREEN  = "playFullScreen"
        const val INSTANCE_KEY_PLAY_ORIENTATION  = "playOrientation"
        const val INSTANCE_KEY_PLAY_URL          = "videoURL"
        const val INSTANCE_KEY_POSITION          = "tabPosition"
        const val INSTANCE_KEY_IS_CAPTION        = "isCaption"
        const val INSTANCE_KEY_VIDEO_DATA        = "videoData"
        const val INSTANCE_KEY_BOTTOM_TITLE      = "bottomPlayTitle"
        const val INSTANCE_KEY_BOTTOM_URL        = "bottomVideoURL"
        const val INSTANCE_KEY_BOTTOM_NAME       = "bottomPlayName"
        const val INSTANCE_KEY_BOTTOM_POSITION   = "bottomPlayerPosition"
        const val INSTANCE_KEY_PLAYLIST_POSITION = "playListPosition"


        /* Query Type */
        const val QUERY_TYPE_FAVORITE            = 1  // 즐겨찾기
        const val QUERY_TYPE_KEM                 = 2  // 국영수
        const val QUERY_TYPE_SCIENCE             = 3  // 과학
        const val QUERY_TYPE_SOCIETY             = 4  // 사회
        const val QUERY_TYPE_ETC                 = 5  // 기타
        const val QUERY_TYPE_PROGRESS            = 6  // 진도탐색
        const val QUERY_TYPE_SEARCH              = 7  // 검색 > 동영상 백과
        const val QUERY_TYPE_TEACHER             = 8  // 강사별
        const val QUERY_TYPE_SERIES              = 9  // 시리즈 보기
        const val QUERY_TYPE_NOTE                = 10 // 검색 > 노트검색
        const val QUERY_TYPE_BEST                = 11 // 추천 동영상
        const val QUERY_TYPE_KEM_PROBLEM         = 12 // 국영수 문제풀이
        const val QUERY_TYPE_SCIENCE_PROBLEM     = 13 // 과학 문제풀이
        const val QUERY_TYPE_SOCIETY_PROBLEM     = 14 // 사회 문제풀이
        const val QUERY_TYPE_ETC_PROBLEM         = 15 // 기타 문제풀이
        const val QUERY_TYPE_RECENT_VIDEO        = 16 // 최근 영상
        const val QUERY_TYPE_HOT                 = 17 // 인기 영상

        /* Note Type */
        const val NOTE_TYPE_KEM                 = 0     //국영수 노트
        const val NOTE_TYPE_SCIENCE             = 1     //과학 노트
        const val NOTE_TYPE_SOCIETY             = 2     //사회 노트
        const val NOTE_TYPE_ETC                 = 3     //기타 노트
        const val NOTE_TYPE_ACTIVE              = 4     //나의활동 노트
        const val NOTE_TYPE_SEARCH              = 5     //검색 노트

        /* Date Time Key */
        const val SECONDS                        = 1000L
        const val MINUTES                        = SECONDS * 60
        const val HOURS                          = MINUTES * 60
        const val DAYS                           = HOURS * 24
        const val WEEKS                          = DAYS * 7
        const val MONTHS                         = WEEKS * 4
        const val YEARS                          = MONTHS * 30

        /* Grade Sort Id */
        const val GRADE_SORT_ID_KEM              = 34
        const val GRADE_SORT_ID_SOCIETY          = 35
        const val GRADE_SORT_ID_SCIENCE          = 36
        const val GRADE_SORT_ID_ETC              = 37

        /* Best Values And Type */
        const val BEST_BANNER_COUNT              = 10
        const val BEST_TYPE                      = "viewType"
        const val BEST_BANNER_TYPE               = 0
        const val BEST_TITLE_TYPE                = 1
        const val BEST_RV_TYPE                   = 2
        const val BEST_LOADING_TYPE              = 3
        const val BEST_TITLE_VALUE               = "BEST!"

        /* Register Activity Type */
        const val REGISTER_TYPE_PRIVACY          = 0
        const val REGISTER_TYPE_FORM             = 1
        const val REGISTER_TYPE_VERIFICATION     = 2
        const val REGISTER_TYPE_DONE             = 3

        /* Counsel View Type */
        const val COUNSEL_TYPE_IMAGE             = 0
        const val COUNSEL_TYPE_VIDEO             = 1

        /* Counsel View Type */
        const val SUBJECT_COMMENTARY_PROBLEM     = 1
        const val SUBJECT_COMMENTARY_ALL         = 0

        /* Endless Scrolling View Type */
        const val VIEW_TYPE_ITEM                 = 0
        const val VIEW_TYPE_LOADING              = 1

        /* Purchase IDuration Key */
        const val PURCHASE_DURATION_30DAYS       = "30"
        const val PURCHASE_DURATION_90DAYS       = "90"
        const val PURCHASE_DURATION_150DAYS      = "150"
        const val PURCHASE_DURATION_365DAYS      = "365"

        /* Purchase Duration Value */
        const val PURCHASE_DURATION_30DAYS_VALUE = "30days"
        const val PURCHASE_DURATION_90DAYS_VALUE = "90days_new"
        const val PURCHASE_DURATION_150DAYS_VALUE= "150days_new"
        // 현재 사용하지 않고있음
        const val PURCHASE_DURATION_365DAYS_VALUE= "1year_new"
        const val PURCHASE_DURATION_TEST_VALUE   = "android.test.purchased"


        /* Intent Extras Key */
        const val EXTRA_KEY_ITEMS                = "items"
        const val EXTRA_KEY_PUSH                 = "push"
        const val EXTRA_KEY_DEEP_LINK            = "deepLink"

        const val EXTRA_KEY_TOKEN                = "token"
        const val EXTRA_KEY_REFRESH_TOKEN        = "refresh_token"
        const val EXTRA_KEY_USER                 = "user"
        const val EXTRA_KEY_USER_NAME            = "username"
        const val EXTRA_KEY_VIDEO_QUERY          = "videoQuery"

        const val EXTRA_KEY_VIDEO_ID             = "video_id"
        const val EXTRA_KEY_TYPE                 = "type"
        const val EXTRA_KEY_TYPE2                = "type2"
        const val EXTRA_KEY_SORTING              = "sorting"
        const val EXTRA_KEY_NOW_POSITION         = "nowPosition"
        const val EXTRA_KEY_TOTAL_NUM            = "totalNum"
        const val EXTRA_KEY_BACK_PRESSED         = "onBackPressed"

        const val EXTRA_KEY_NOTE_DATA            = "noteData"
        const val EXTRA_KEY_NOTE_JSON            = "json"
        const val EXTRA_KEY_VIDEO_PLAYER         = "videoPlayer"
        const val EXTRA_KEY_VIDEO_URL            = "videoURL"

        const val EXTRA_KEY_VIDEO_POSITION       = "videoPosition"
        const val EXTRA_KEY_BOTTOM_SERIES_ID     = "bottomSeriesId"
        const val EXTRA_KEY_BOTTOM_SUBJECT_ID    = "bottomSubjectId"
        const val EXTRA_KEY_BOTTOM_GRADE         = "bottomGrade"
        const val EXTRA_KEY_BOTTOM_KEYWORD       = "bottomKeyword"
        const val EXTRA_KEY_BOTTOM_SORTING       = "bottomSorting"
        const val EXTRA_KEY_BOTTOM_QUERY_TYPE    = "bottomQueryType"
        const val EXTRA_KEY_BOTTOM_NOW_POSITION  = "bottomNowPosition"
        const val EXTRA_KEY_JINDO_ID             = "jindo_id"
        const val EXTRA_KEY_QUERY                = "query"
        const val EXTRA_KEY_POSITION             = "position"
        const val EXTRA_KEY_IS_AUTO              = "isAutoPlay"

        const val EXTRA_KEY_KEYWORD              = "keyword"
        const val EXTRA_KEY_SERIES_ID            = "series_id"
        const val EXTRA_KEY_GRADE                = "grade"
        const val EXTRA_KEY_SUBJECT_ID           = "subjectId"
        const val EXTRA_KEY_VIDEO_TITLE          = "title"
        const val EXTRA_KEY_TEACHER_NAME         = "teacherName"
        const val EXTRA_KEY_SEARCH_NOTE          = "searchNote"
        const val EXTRA_KEY_PROGRESS             = "progress"
        const val EXTRA_KEY_ONE_TO_ONE           = "one_to_one"
        const val EXTRA_KEY_QNA_ID               = "qna_id"
        const val EXTRA_KEY_NOTICE               = "notice"
        const val EXTRA_KEY_EVENT                = "event"
        const val EXTRA_KEY_COUNSEL              = "counsel"
        const val EXTRA_KEY_CALENDAR_NOW_DATE    = "nowDate"
        const val EXTRA_KEY_CALENDAR_CLICK_DATE  = "clickDate"
        const val EXTRA_KEY_CALENDAR_SCHEDULE    = "schedule"
        const val EXTRA_KEY_CALENDAR_TYPE        = "type"
        const val EXTRA_KEY_DATA                 = "data"
        const val EXTRA_KEY_BOTTOM_VIDEO_ID      = "bottomId"
        const val EXTRA_KEY_OFFSET               = "offset"
        const val EXTRA_KEY_TAB_POSITION         = "tabPosition"

        /* Activity ActionBar Title */
        const val ACTIONBAR_TITLE_REGISTER        = "회원가입"
        const val ACTIONBAR_TITLE_FIND_ID         = "아이디 찾기"
        const val ACTIONBAR_TITLE_FIND_PASSWORD   = "비밀번호 찾기"
        const val ACTIONBAR_TITLE_REGISTER_UPDATE = "프로필 편집"
        const val ACTIONBAR_TITLE_PASS            = "이용권"
        const val ACTIONBAR_TITLE_MY_ACTIVITY     = "나의 활동"
        const val ACTIONBAR_TITLE_COUNSEL         = "전문가상담"
        const val ACTIONBAR_TITLE_TEACHER         = "강사별 강의"
        const val ACTIONBAR_TITLE_SETTING         = "설정"
        const val ACTIONBAR_TITLE_JINDO           = "진도학습"
        const val ACTIONBAR_TITLE_RELATION_SERIES = "관련 시리즈"
        const val ACTIONBAR_TITLE_SEARCH          = "검색"
        const val ACTIONBAR_TITLE_SCHEDULE        = "나의 일정"
        const val ACTIONBAR_TITLE_SCHEDULE_SETTING= "일정 설정"
        const val ACTIONBAR_TITLE_SERIES          = " 시리즈보기"
        const val ACTIONBAR_TITLE_NOTICE          = "공지사항"
        const val ACTIONBAR_TITLE_WHAT_S_GONGMANSE= "공만세란?"
        const val ACTIONBAR_TITLE_ALARM           = "알림"
        const val ACTIONBAR_TITLE_TERMS_OF_SERVICE= "이용약관"
        const val ACTIONBAR_TITLE_PRIVACY_POLICY  = "개인 정보 처리 방침"
        const val ACTIONBAR_TITLE_CUSTOMER_SERVICE= "고객센터"
        const val ACTIONBAR_TITLE_NOTE_SHOW       = "노트보기"
        const val ACTIONBAR_TITLE_QNA             = "문의하기"
        const val ACTIONBAR_TITLE_SCHEDULE_REG    = "일정등록"
        const val ACTIONBAR_TITLE_SCHEDULE_MOD    = "일정수정"

        /* Button Text */
        const val BUTTON_TEXT_COUNSEL             = "작성하기"
        const val BUTTON_TEXT_REG                 = "등록하기"

        /* Empty Text */
        const val TEXT_VIEW_IMAGE_EMPTY           = "등록된 이미지가 없습니다."

        /* Home Fragment Tab Title*/
        const val HOME_TAB_TITLE_BEST            = "추천"
        const val HOME_TAB_TITLE_HOT             = "인기"
        const val HOME_TAB_TITLE_KEM             = "국영수"
        const val HOME_TAB_TITLE_SCIENCE         = "과학"
        const val HOME_TAB_TITLE_SOCIETY         = "사회"
        const val HOME_TAB_TITLE_ETC             = "기타"

        /* Progress Fragment Tab Title*/
        const val PROGRESS_TAB_TITLE_KEM         = "국영수"
        const val PROGRESS_TAB_TITLE_SCIENCE     = "과학"
        const val PROGRESS_TAB_TITLE_SOCIETY     = "사회"
        const val PROGRESS_TAB_TITLE_ETC         = "기타과목"

        /* Search Fragment Tab Title*/
        const val SEARCH_TAB_TITLE_HOT           = "인기 검색어"
        const val SEARCH_TAB_TITLE_RECENT        = "최근 검색어"
        const val SEARCH_TAB_TITLE_VIDEO         = "동영상 백과"
        const val SEARCH_TAB_TITLE_COUNSEL       = "전문가상담"
        const val SEARCH_TAB_TITLE_NOTE          = "노트 검색"

        /* Pass Activity Tab Title */
        const val PASS_TAB_TITLE_STORE           = "스토어"
        const val PASS_TAB_TITLE_HISTORY         = "결제내역"

        /* Active Fragment Tab Title*/
        const val ACTIVE_TAB_TITLE_RECENT_VIDEO    = "최근 영상"
        const val ACTIVE_TAB_TITLE_NOTE            = "노트 목록"
        const val ACTIVE_TAB_TITLE_QNA             = "강의 Q&A"
        const val ACTIVE_TAB_TITLE_QUESTION        = "전문가 상담"
        const val ACTIVE_TAB_TITLE_FAVORITES       = "즐겨찾기"

        /*  Notice Fragment Tab Title*/
        const val NOTICE_TAB_TITLE_NOTICE        = "공지사항"
        const val NOTICE_TAB_TITLE_EVENT         = "이벤트"

        /*  Customer Fragment Tab Title*/
        const val CUSTOMER_TAB_TITLE_FAQ        = "자주 묻는 질문"
        const val CUSTOMER_TAB_TITLE_ONE        = "1:1 문의"

        /* Notice Value */
        const val NOTICE_VALUE_WEB_VIEW         = "/notices/view/"


        /* Notice Event Value */
        const val NOTICE_VALUE_STATUS_TRUE       = "진행중"
        const val NOTICE_VALUE_STATUS_FALSE      = "종료"

        /* One To One Event Value */
        const val OnToON_VALUE_STATUS_TRUE        = "답변 완료 >"
        const val OnToON_VALUE_STATUS_FALSE       = "대기중 >"

        /* What is Gongmanse */
        const val WHAT_TAB_TITLE_STORY           = "공만세 이야기"
        const val WHAT_TAB_TITLE_HOW_USE         = "강의 이용방법"
        const val WHAT_TAB_TITLE_TEACHER_INTRO   = "강사 소개"

        /* Receiver Type */
        const val RECEIVER_TYPE_EMAIL            = "email"
        const val RECEIVER_TYPE_PHONE            = "cellphone"

        /* Share SNS Type */
        const val CONTENT_SHARE_SNS_TYPE_KAKAO   = "kakao"
        const val CONTENT_SHARE_SNS_TYPE_FACEBOOK= "facebook"
        // 공만세 DB 등록용
        const val CONTENT_SHARE_SNS_TYPE_KK      = "kk"
        const val CONTENT_SHARE_SNS_TYPE_FB      = "fb"

        /* Select Value */
        const val CONTENT_VALUE_ALL              = "전체보기"
        const val CONTENT_VALUE_ALL_GRADE_SERVER = "전체"
        const val CONTENT_VALUE_SERIES           = "시리즈보기"
        const val CONTENT_VALUE_PROBLEM          = "문제풀이"
        const val CONTENT_VALUE_NOTE             = "노트보기"
        const val CONTENT_VALUE_ALL_GRADE        = "모든 학년"
        const val CONTENT_VALUE_ALL_UNIT         = "모든 단원"
        const val CONTENT_VALUE_ALL_SUBJECT      = "모든 과목"
        const val CONTENT_VALUE_AVG              = "평점순"
        const val CONTENT_VALUE_LATEST           = "최신순"
        const val CONTENT_VALUE_NAME             = "이름순"
        const val CONTENT_VALUE_SUBJECT          = "과목순"
        const val CONTENT_VALUE_VIEWS            = "조회순"
        const val CONTENT_VALUE_RELEVANCE        = "관련순"
        const val CONTENT_VALUE_ANSWER           = "답변 완료순"

        /* Select Value */
        const val CONTENT_RESPONSE_VALUE_NAME             = 1   //이름순
        const val CONTENT_RESPONSE_VALUE_SUBJECT          = 2   //과목순
        const val CONTENT_RESPONSE_VALUE_AVG              = 3   //평점순
        const val CONTENT_RESPONSE_VALUE_LATEST           = 4   //최신순
        const val CONTENT_RESPONSE_VALUE_VIEWS            = 5   //조회순
        const val CONTENT_RESPONSE_VALUE_ANSWER           = 6   //답변완료순?
        const val CONTENT_RESPONSE_VALUE_RELEVANCE        = 7   //관련순

        /* Toast Message */
        const val TOAST_MESSAGE_LOGIN            = "아이디 또는 비밀번호를 다시 확인해주세요."

        /* Series Value */
        const val CONTENT_VALUE_TEACHER          = "선생님"
        const val CONTENT_VALUE_COLOR            = "#"

        /* Grade Type*/
        const val CONTENT_VALUE_ELEMENTARY       = "초등"
        const val CONTENT_VALUE_ELEMENTARY_VIEW  = "초"
        const val CONTENT_VALUE_MIDDLE           = "중등"
        const val CONTENT_VALUE_MIDDLE_VIEW      = "중"
        const val CONTENT_VALUE_HIGH             = "고등"
        const val CONTENT_VALUE_HIGH_VIEW        = "고"

        const val CONTENT_VALUE_ELEMENTARY_first = "초등학교 1학년"
        const val CONTENT_VALUE_ELEMENTARY_second= "초등학교 2학년"
        const val CONTENT_VALUE_ELEMENTARY_third = "초등학교 3학년"
        const val CONTENT_VALUE_ELEMENTARY_fourth= "초등학교 4학년"
        const val CONTENT_VALUE_ELEMENTARY_fifth = "초등학교 5학년"
        const val CONTENT_VALUE_ELEMENTARY_sixth = "초등학교 6학년"
        const val CONTENT_VALUE_MIDDLE_first     = "중학교 1학년"
        const val CONTENT_VALUE_MIDDLE_second    = "중학교 2학년"
        const val CONTENT_VALUE_MIDDLE_third     = "중학교 3학년"
        const val CONTENT_VALUE_HIGH_first       = "고등학교 1학년"
        const val CONTENT_VALUE_HIGH_second      = "고등학교 2학년"
        const val CONTENT_VALUE_HIGH_third       = "고등학교 3학년"

        const val CONTENT_VALUE_GRADE_NUM_FIRST  = 1
        const val CONTENT_VALUE_GRADE_NUM_SECOND = 2
        const val CONTENT_VALUE_GRADE_NUM_THIRD  = 3
        const val CONTENT_VALUE_GRADE_NUM_FOURTH = 4
        const val CONTENT_VALUE_GRADE_NUM_FIFTH  = 5
        const val CONTENT_VALUE_GRADE_NUM_SIXTH  = 6

        /* Setting Value */
        const val CONTENT_VALUE_SUBTITLE_ON      = "적용"
        const val CONTENT_VALUE_SUBTITLE_OFF     = "미적용"

        /* My Active Unit Value */
        const val CONTENT_VALUE_ACTIVE_UNIT_TERM            = "용어"
        const val CONTENT_VALUE_ACTIVE_UNIT_ONE             = "1"
        const val CONTENT_VALUE_ACTIVE_UNIT_ONE_VIEW        = "ⅰ"
        const val CONTENT_VALUE_ACTIVE_UNIT_TWO             = "2"
        const val CONTENT_VALUE_ACTIVE_UNIT_TWO_VIEW        = "ⅱ"

        /* Offset Default Value */
        const val OFFSET_DEFAULT                 = "0"
        const val OFFSET_DEFAULT_INT             = 0
        const val LIMIT_DEFAULT                  = "20"
        const val LIMIT_DEFAULT_INT              = 20
        const val LIMIT_MAX_INT                  = Int.MAX_VALUE

        /* Calendar Value */
        const val CONTENT_VALUE_SUN             = "일"
        const val CONTENT_VALUE_SAT             = "토"
        const val CONTENT_VALUE_EMPTY_SCHEDULE  = "등록된 일정이 없습니다."
        const val CONTENT_VALUE_REPEAT_DAY      = "매일"
        const val CONTENT_VALUE_REPEAT_MONTH    = "매월"
        const val CONTENT_VALUE_REPEAT_YEAR     = "매년"
        const val CONTENT_VALUE_REPEAT_NULL     = "없음"
        const val CONTENT_VALUE_BUTTON_TEXT     = "수정하기"


        /* One TO One QNA Value */
        const val CONTENT_TYPE_HOW_USE          = "[이용방법]"
        const val CONTENT_TYPE_SERVICE_ERROR    = "[서비스 장애]"
        const val CONTENT_TYPE_PAYMENT          = "[결제 및 인증]"
        const val CONTENT_TYPE_OTHER_ASSISTANCE = "[기타 문의]"
        const val CONTENT_TYPE_LECTURE_REQUEST  = "[강의 요청]"

        /* Retrofit REQUEST Body key */
        const val REQUEST_KEY_TOKEN              = "token"
        const val REQUEST_KEY_VIDEO              = "video"
        const val REQUEST_KEY_ID                 = "id"
        const val REQUEST_KEY_QNA_ID             = "qna_id"
        const val REQUEST_KEY_VIDEO_ID           = "video_id"
        const val REQUEST_KEY_HISTORY_ID         = "history_id"
        const val REQUEST_KEY_BOOKMARK_ID        = "bookmark_id"
        const val REQUEST_KEY_COMMENTARY         = "commentary"
        const val REQUEST_KEY_OFFSET             = "offset"
        const val REQUEST_KEY_LIMIT              = "limit"
        const val REQUEST_KEY_GRANT_TYPE         = "grant_type"
        const val REQUEST_KEY_GRANT_REFRESH      = "refresh_token"
        const val REQUEST_KEY_GRANT_LOGIN        = "password"
        const val REQUEST_KEY_REFRESH            = "refresh_token"
        const val REQUEST_KEY_USERNAME           = "username"
        const val REQUEST_KEY_PASSWORD           = "password"
        const val REQUEST_KEY_PASSWORD_CONFIRM   = "confirm_password"
        const val REQUEST_KEY_NAME               = "first_name"
        const val REQUEST_KEY_NICKNAME           = "nickname"
        const val REQUEST_KEY_EMAIL              = "email"
        const val REQUEST_KEY_PHONE_NUMBER       = "phone_number"
        const val REQUEST_KEY_VERIFICATION_CODE  = "verification_code"
        const val REQUEST_KEY_SORT_ID            = "sort_id"
        const val REQUEST_KEY_JINDO_ID           = "jindo_id"
        const val REQUEST_KEY_GRADE              = "grade"
        const val REQUEST_KEY_SUBJECT            = "subject"
        const val REQUEST_KEY_KEYWORD            = "keyword"
        const val REQUEST_KEY_KEYWORD_ID         = "keyword_id"
        const val REQUEST_KEY_IGRADE             = "igrade"
        const val REQUEST_KEY_WITH               = "with"
        const val REQUEST_KEY_SOURCE_URL         = "source_url"
        const val REQUEST_KEY_RATING_VALUE       = "rating"
        const val REQUEST_KEY_NOTE_ID            = "note_id"
        const val REQUEST_KEY_WORDS              = "words"
        const val REQUEST_KEY_CATEGORY_ID        = "category_id"
        const val REQUEST_KEY_SERIES_ID          = "series_id"
        const val REQUEST_KEY_TEACHER_ID         = "instructor_id"
        const val REQUEST_KEY_JSON               = "sjson"
        const val REQUEST_KEY_IMAGE              = "image"
        const val REQUEST_KEY_QUESTION           = "question"
        const val REQUEST_KEY_TYPE               = "type"
        const val REQUEST_KEY_FILE               = "file"
        const val REQUEST_KEY_USER_ID            = "user_id"
        const val REQUEST_KEY_OS_TYPE            = "os_type"
        const val REQUEST_KEY_CALENDAR_MY        = "iShowMy"
        const val REQUEST_KEY_CALENDAR_CEREMONY  = "iShowCeremony"
        const val REQUEST_KEY_CALENDAR_EVENT     = "iShowEvent"
        const val REQUEST_KEY_PURCHASE_TOKEN     = "purchaseToken"
        const val REQUEST_KEY_SKU                = "sku"
        const val REQUEST_KEY_ORDER_ID           = "orderId"

        const val REQUEST_KEY_FOR_TODAY          = "for_today"
        const val REQUEST_KEY_FOR_TODAY_VALUE    = 1
        const val REQUEST_KEY_FIELD              = "filter[target]"
        const val REQUEST_KEY_FIELD_VALUE        = "field"
        const val REQUEST_KEY_SHARE              = "filter[value]"
        const val REQUEST_KEY_SHARE_VALUE        = "iShare"
        const val REQUEST_KEY_SHARE_SOCIAL_TYPE  = "value"

        const val RESPONSE_KEY_SUSERNAME          = "sUsername"
        const val RESPONSE_KEY_SNICKNAME          = "sNickname"
        const val RESPONSE_KEY_SFIRSENAME         = "sFirstName"
        const val RESPONSE_KEY_SIMAGE             = "sImage"
        const val RESPONSE_KEY_SEMAIL             = "sEmail"
        const val RESPONSE_KEY_STYPE              = "eType"
        const val RESPONSE_KEY_NUM                = "num"
        const val RESPONSE_KEY_DTPREMIUMACTIVE    = "dtPremiumActivate"
        const val RESPONSE_KEY_DTPREMINUMEXPIRE   = "dtPremiumExpire"
        const val RESPONSE_KEY_SDATA              = "sData"
        const val RESPONSE_KEY_BODY               = "sBody"
        const val RESPONSE_KEY_DATA               = "data"
        const val RESPONSE_KEY_SHARE_URL          = "share_url"
        const val RESPONSE_KEY_SHARE_COUNT        = "countFiltered"
        const val RESPONSE_KEY_SHARE_TYPE         = "sType"
        const val RESPONSE_KEY_SHARE_FIELD        = "sField"
        const val RESPONSE_KEY_SHARE_VALUE        = "sValue"
        const val RESPONSE_KEY_SHARE_DT           = "dtTimestamp"



        const val RESPONSE_KEY_DATA_OK            = "1"
        const val RESPONSE_KEY_IS_MORE            = "isMore"
        const val RESPONSE_KEY_TOTAL_NUM          = "totalNum"
        const val RESPONSE_KEY_TOTAL_COUNT        = "totalCount"
        const val RESPONSE_KEY_ID                 = "id"
        const val RESPONSE_KEY_USER_ID            = "user_id"
        const val RESPONSE_KEY_VIDEO_ID           = "video_id"
        const val RESPONSE_KEY_JINDO_ID           = "iJindoId"
        const val RESPONSE_KEY_CATEGORY_ID        = "iCategoryId"
        const val RESPONSE_KEY_SERIES             = "seriesInfo"
        const val RESPONSE_KEY_SERIES_ID          = "iSeriesId"
        const val RESPONSE_KEY_QNA_ID             = "sQid"
        const val RESPONSE_KEY_COMMENTARY_ID      = "iCommentaryId"
        const val RESPONSE_KEY_BOOKMARK_ID        = "iBookmarkId"
        const val RESPONSE_KEY_HAS_COMMENTARY     = "iHasCommentary"
        const val RESPONSE_KEY_COUNSEL_ID         = "consultation_id"
        const val RESPONSE_KEY_CU_ID              = "cu_id"
        const val RESPONSE_KEY_PRIORITY           = "sPriority"
        const val RESPONSE_KEY_SERIES_COUNT       = "iCount"
        const val RESPONSE_KEY_WORDS              = "sWords"
        const val RESPONSE_KEY_TITLE              = "sTitle"
        const val RESPONSE_KEY_TYPE               = "eType"
        const val RESPONSE_KEY_ITYPE              = "iType"
        const val RESPONSE_KEY_STATUS             = "sStatus"
        const val RESPONSE_KEY_JINDOTITLE         = "sJindoTitle"
        const val RESPONSE_KEY_SUBJECT            = "sSubject"
        const val RESPONSE_KEY_SUBJECT_COLOR      = "sSubjectColor"
        const val RESPONSE_KEY_TEACHER            = "sTeacher"
        const val RESPONSE_KEY_QUESTION           = "sQuestion"
        const val RESPONSE_KEY_NAME               = "sName"
        const val RESPONSE_KEY_NICKNAME           = "sNickname"
        const val RESPONSE_KEY_PROFILE            = "sProfile"
        const val RESPONSE_KEY_ANSWER             = "iAnswer"
        const val RESPONSE_KEY_ANSWER_STR         = "sAnswer"
        const val RESPONSE_KEY_RATE               = "sRate"
        const val RESPONSE_KEY_THUMBNAIL          = "sThumbnail"
        const val RESPONSE_KEY_BOOKMARKS          = "sBookmarks"
        const val RESPONSE_KEY_AVG                = "sAvg"
        const val RESPONSE_KEY_RATING             = "iRating"
        const val RESPONSE_KEY_RATING_COUNT       = "iRatingNum"
        const val RESPONSE_KEY_USER_RATE          = "iUserRating"
        const val RESPONSE_KEY_VIDEO_PATH         = "sVideopath"
        const val RESPONSE_KEY_SUBTITLE_PATH      = "sSubtitle"
        const val RESPONSE_KEY_TAGS               = "sTags"
        const val RESPONSE_KEY_HIGHLIGHT          = "sHighlight"
        const val RESPONSE_KEY_UNIT               = "sUnit"
        const val RESPONSE_KEY_REGISTER_DATE      = "dtRegister"
        const val RESPONSE_KEY_URI                = "sUri"
        const val RESPONSE_KEY_CREATE_DATE        = "dtDateCreated"
        const val RESPONSE_KEY_LAST_UPDATE        = "dtLastUpdated"
        const val RESPONSE_KEY_QUESTION_DATE      = "sQdatecreated"
        const val RESPONSE_KEY_ANSWER_DATE        = "sAdatecreated"
        const val RESPONSE_KEY_LAST_START_DATE    = "dtStartDate"
        const val RESPONSE_KEY_LAST_END_DATE      = "dtEndDate"
        const val RESPONSE_KEY_GRADE              = "sGrade"
        const val RESPONSE_KEY_FIRST_GRADE        = "iGrade"
        const val RESPONSE_KEY_SECOND_GRADE       = "iGrade2"
        const val RESPONSE_KEY_THIRD_GRADE        = "iGrade3"
        const val RESPONSE_KEY_SETTING_SUB_ID     = "iPreferCategory"
        const val RESPONSE_KEY_NOTES              = "sNotes"
        const val RESPONSE_KEY_JSON_POINT         = "sJson"
        const val RESPONSE_KEY_KEYWORDS           = "keywords"
        const val RESPONSE_KEY_ANSWER_CONTENT     = "sAnswer"
        const val RESPONSE_KEY_COUNSEL_PATH       = "sFilePath"
        const val RESPONSE_KEY_SOURCE_URL         = "source_url"
        const val RESPONSE_KEY_ACTIVE             = "iActive"
        const val RESPONSE_KEY_VIDEO_PATH2        = "sVideopath"
        const val RESPONSE_KEY_USER_PROFILE       = "sUserImg"
        const val RESPONSE_KEY_TEACHER_PROFILE    = "sTeacherImg"
        const val RESPONSE_KEY_QNA_CONTENT        = "content"
        const val RESPONSE_KEY_SEARCH_HOT         = "sTop"
        const val RESPONSE_KEY_VIEWS              = "iViews"
        const val RESPONSE_KEY_DESCRIPTION        = "sDescription"
        const val RESPONSE_KEY_WHOLE_DAY          = "iWholeDay"
        const val RESPONSE_KEY_REPEAT_COUNT       = "iRepeatCount"
        const val RESPONSE_KEY_REPEAT_RADIO       = "sRepeatRadioCode"
        const val RESPONSE_KEY_ALARM_CODE         = "sAlarmCode"
        const val RESPONSE_KEY_REPEAT_CODE        = "sRepeatCode"
        const val RESPONSE_KEY_CONTENT_IMAGE      = "sContent"
        const val RESPONSE_KEY_CONTENT_LIST_IMAGE = "sFilepaths"
        const val RESPONSE_KEY_CONTENT_DATE       = "Date"
        const val RESPONSE_KEY_ASPECT_RATIO      = "aspectRatio"
        const val RESPONSE_KEY_STROKES           = "strokes"
        const val RESPONSE_KEY_POINTS            = "points"
        const val RESPONSE_KEY_POINTS_X          = "x"
        const val RESPONSE_KEY_POINTS_Y          = "y"
        const val RESPONSE_KEY_COLOR             = "color"
        const val RESPONSE_KEY_SIZE              = "size"
        const val RESPONSE_KEY_CAP               = "cap"
        const val RESPONSE_KEY_JOIN              = "join"
        const val RESPONSE_KEY_MITER_LIMIT       = "miterLimit"
        const val RESPONSE_KEY_CALENDAR_DATE    = "date"
        const val RESPONSE_KEY_CALENDAR_DESCRIPTION = "description"
        const val RESPONSE_KEY_CALENDAR_MY          = "iShowMy"
        const val RESPONSE_KEY_CALENDAR_CEREMONY    = "iShowCeremony"
        const val RESPONSE_KEY_CALENDAR_EVENT       = "iShowEvent"

        const val RESPONSE_KEY_DURATION          = "iDuration"
        const val RESPONSE_KEY_PAY_METHOD        = "sPayMethod"
        const val RESPONSE_KEY_PREMIUM_ACTIVE    = "dtPremiumActivate"
        const val RESPONSE_KEY_PREMIUM_EXPIRE    = "dtPremiumExpire"
        const val RESPONSE_KEY_DATE_INITIATE     = "dtInitiateDate"
        const val RESPONSE_KEY_PRICE             = "iPrice"

        /* Subject Name List */
        const val SUBJECT_NAME_IS_KOREAN              = "국어"
        const val SUBJECT_NAME_IS_ENGLISH             = "영어"
        const val SUBJECT_NAME_IS_MATH                = "수학"
        const val SUBJECT_NAME_IS_SOCIETY             = "사회"
        const val SUBJECT_NAME_IS_HISTORY             = "역사"
        const val SUBJECT_NAME_IS_SCIENCE             = "과학"
        const val SUBJECT_NAME_IS_MUSIC               = "음악"
        const val SUBJECT_NAME_IS_CHINESE_WRITING     = "한문"
        const val SUBJECT_NAME_IS_TECHNOLOGY_HOME     = "기술&가정"
        const val SUBJECT_NAME_IS_PHYSICS             = "물리"
        const val SUBJECT_NAME_IS_CHEMISTRY           = "화학"
        const val SUBJECT_NAME_IS_LIFE_SCIENCE        = "생명과학"
        const val SUBJECT_NAME_IS_EARTH_SCIENCE       = "지구과학"
        const val SUBJECT_NAME_IS_LIFE_ETHICS         = "생활과윤리"
        const val SUBJECT_NAME_IS_ETHICS_THOUGHT      = "윤리와사상"
        const val SUBJECT_NAME_IS_KOREAN_GEOGRAPHY    = "한국지리"
        const val SUBJECT_NAME_IS_WORLD_GEOGRAPHY     = "세계지리"
        const val SUBJECT_NAME_IS_POLITICS_LAW        = "정치와법"
        const val SUBJECT_NAME_IS_ECONOMY             = "경제"
        const val SUBJECT_NAME_IS_SOCIAL_CULTURE      = "사회문화"
        const val SUBJECT_NAME_IS_KOREAN_HISTORY      = "한국사&근현대사"
        const val SUBJECT_NAME_IS_EAST_ASIA           = "동아시아"
        const val SUBJECT_NAME_IS_WORLD_HISTORY       = "세계사"
        const val SUBJECT_NAME_IS_ESSAY               = "논술"
        const val SUBJECT_NAME_IS_IDIOM               = "사자성어&고사성어"
        const val SUBJECT_NAME_IS_NON_LITERATURE      = "비문학"
        const val SUBJECT_NAME_IS_ENGLISH__VOCABULARY = "영어어휘&영어회화"
        const val SUBJECT_NAME_IS_PASSING_EVENTS      = "시사"
        const val SUBJECT_NAME_IS_INFORMATION         = "정보"
        const val SUBJECT_NAME_IS_SPEECH_COMPOSITION  = "화법과작문"
        const val SUBJECT_NAME_IS_INTEGRATED_SCIENCE  = "통합과학"
        const val SUBJECT_NAME_IS_MORALITY            = "도덕"
        const val SUBJECT_NAME_IS_UNIFIED_SOCIETY     = "통합사회"
        const val SUBJECT_NAME_IS_A_COMMON_SAYING     = "사자성어&고사성어&속담"

        const val INTRO_POSITION                      = "position"

        fun dpToPx(context: Context, dp: Int): Int = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp.toFloat(), context.resources.displayMetrics).toInt()

        fun isTablet(context: Context): Boolean {
            val screenSizeType = context.resources.configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK
            return screenSizeType == Configuration.SCREENLAYOUT_SIZE_XLARGE || screenSizeType == Configuration.SCREENLAYOUT_SIZE_LARGE
        }

        fun isTabletDevice(context: Context): Boolean {
            return if (Build.VERSION.SDK_INT >= 19) {
                checkTabletDeviceWidthScreenSize(context)
                        && checkTabletDeviceWithProperties()
                        && checkTabletDeviceWithUserAgent(context)
            } else {
                checkTabletDeviceWidthScreenSize(context)
                        && checkTabletDeviceWithProperties()
            }
        }

        private fun checkTabletDeviceWidthScreenSize(context: Context): Boolean {
            val deviceLarge = ((context.resources.configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_LARGE)
            if (deviceLarge) {
                val metrics = DisplayMetrics()
                val activity = context as Activity
                activity.windowManager.defaultDisplay.getMetrics(metrics)

                if (metrics.densityDpi == DisplayMetrics.DENSITY_DEFAULT
                    || metrics.densityDpi == DisplayMetrics.DENSITY_HIGH
                    || metrics.densityDpi == DisplayMetrics.DENSITY_MEDIUM
                    || metrics.densityDpi == DisplayMetrics.DENSITY_TV
                    || metrics.densityDpi == DisplayMetrics.DENSITY_XHIGH) {
                    return true
                }
            }
            return false
        }

        private fun checkTabletDeviceWithProperties(): Boolean {
            return try {
                val ism = Runtime.getRuntime().exec("getprop ro.build.characteristics").inputStream
                val bts = ByteArray(1024)
                ism.read(bts)
                ism.close()
                String(bts).toLowerCase().contains("tablet")
            } catch (t: Throwable) {
                t.printStackTrace()
                false
            }
        }

        private fun checkTabletDeviceWithUserAgent(context: Context): Boolean {
            var webView: WebView? = WebView(context)
            val ua = webView?.settings?.userAgentString
            webView = null
            return ua?.contains("Mobile Safari") ?: false
        }

        fun getImageFromURLToBitmap(imageUrl: String): Bitmap? {
            var imgBitmap: Bitmap? = null
            var conn: HttpsURLConnection? = null
            var bis: BufferedInputStream? = null

            try {
                val url = URL(imageUrl)
                conn = url.openConnection() as HttpsURLConnection
                conn.connect()

                val nSize = conn.contentLength
                bis = BufferedInputStream(conn.inputStream, nSize)
                imgBitmap = BitmapFactory.decodeStream(bis)
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                if (bis != null) {
                    try {
                        bis.close()
                    } catch (e: IOException) {}
                }
                conn?.disconnect()
            }

            return imgBitmap
        }

        fun payloadLink(context: Context, deepLink: String?) {
            Log.d("Payload", "link : $deepLink")
            context.apply {
                deepLink?.let { t ->
                    when {
                        t.startsWith("/notices") -> {
                            val id = t.substring(t.lastIndexOf('/').plus(1))
                            startActivity(Intent(this, NoticeDetailWebViewActivity::class.java).apply {
                                putExtra(Constants.EXTRA_KEY_NOTICE, NoticeData(id, null, null, null, null, null))
                            })
                        }
                        t.startsWith("/events") -> {
                            val id = t.substring(t.lastIndexOf('/').plus(1))
                            startActivity(Intent(this, NoticeDetailWebViewActivity::class.java).apply {
                                putExtra(Constants.EXTRA_KEY_EVENT, EventData(id, null, null, null, null, null, null, null))
                            })
                        }
                        t.startsWith("/my/inquiries") -> {
                            val id = t.substring(t.lastIndexOf('/').plus(1))
                            startActivity(Intent(this, CustomerServiceDetailActivity::class.java).apply {
                                putExtra(Constants.EXTRA_KEY_ONE_TO_ONE, OneToOneData(0, id.toInt(), null, null, null, null, null))
                            })
                        }
                        t.startsWith("/watch") -> {
                            val start = t.lastIndexOf('/').plus(1)
                            val end = t.lastIndexOf('?')
                            val id = t.substring(start, end)
                            startActivity(Intent(this, VideoActivity::class.java).apply {
                                putExtra(Constants.EXTRA_KEY_VIDEO_ID, id)
                                putExtra(Constants.EXTRA_KEY_TAB_POSITION, 1)
                            })
                        }
                    }
                }
            }
        }

        // 프로필 정보 로드
        fun getProfile() {
            Log.v("TAG", "getProfile... => ${Preferences.token}")
            RetrofitClient.getService().getUserInfo(Preferences.token).enqueue(object :
                Callback<User> {
                override fun onFailure(call: Call<User>, t: Throwable) {
                    Log.v("TAG", "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(call: Call<User>, response: Response<User>) {
                    if (response.isSuccessful) {
                        response.body()?.apply {
                            Log.v("TAG", "onResponse => $this")
                            Preferences.expire = this.dtPremiumExpire ?: ""
                        }
                    } else {
                        Log.v("TAG", "Failed API code : ${response.code()}\n message : ${response.message()}")
                    }
                }
            })
        }

    }

    /* Grade Type*/
    class GradeType{
        companion object {
            // Type
            const val All_GRADE        = "모든 학년"
            const val All_VIEW         = '모'
            const val ELEMENTARY       = "초등"
            const val ELEMENTARY_VIEW  = '초'
            const val MIDDLE           = "중등"
            const val MIDDLE_VIEW      = '중'
            const val HIGH             = "고등"
            const val HIGH_VIEW        = '고'

            // Grade Value Num: String
            const val VALUE_GRADE_STRING_NUM_NULL   = "0"
            const val VALUE_GRADE_STRING_NUM_FIRST  = "1"
            const val VALUE_GRADE_STRING_NUM_SECOND = "2"
            const val VALUE_GRADE_STRING_NUM_THIRD  = "3"
            const val VALUE_GRADE_STRING_NUM_FOURTH = "4"
            const val VALUE_GRADE_STRING_NUM_FIFTH  = "5"
            const val VALUE_GRADE_STRING_NUM_SIXTH  = "6"
        }
    }

}
