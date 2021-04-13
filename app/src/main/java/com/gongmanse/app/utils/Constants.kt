package com.gongmanse.app.utils

class Constants {

    companion object {

        /* Server API IP */
        const val BASE_DOMAIN                  = "https://api.gongmanse.com"
        const val FILE_DOMAIN                  = "https://file.gongmanse.com"
        const val WEB_VIEW_DOMAIN              = "https://webview.gongmanse.com"
        const val NOTICE_EVENT_VALUE_DOMAIN    = "https://webview.gongmanse.com/events/view/"
        const val PRIVACY_POLICY_DOMAIN        = "/users/privacy_policy"
        const val TERMS_OF_SERVICE_DOMAIN      = "/users/toa_read"
    }

    /* Delay Value */
    class Delay {
        companion object {
            const val VALUE_OF_ENDLESS         = 1500L
            const val VALUE_OF_SPLASH          = 1500L

        }
    }

    /* Intent Extras Key */
    class Extra {
        companion object {
            const val KEY_TOKEN                = "token"
            const val KEY_REFRESH_TOKEN        = "refresh_token"

        }
    }

    // Retrofit REQUEST Body key
    class Request {
        companion object {
            const val KEY_GRANT_TYPE           = "grant_type"
            const val KEY_REFRESH_TOKEN        = "refresh_token"

        }
        const val BASE_DOMAIN                    = "https://api.gongmanse.com"
        const val FILE_DOMAIN                    = "https://file.gongmanse.com"
        const val WEB_VIEW_DOMAIN                = "https://webview.gongmanse.com"
        const val NOTICE_EVENT_VALUE_DOMAIN      = "https://webview.gongmanse.com/events/view/"
        const val PRIVACY_POLICY_DOMAIN          = "/users/privacy_policy"
        const val TERMS_OF_SERVICE_DOMAIN        = "/users/toa_read"

        /* Delay Value */
        const val DELAY_VALUE_OF_ENDLESS         = 1500L
        const val DELAY_VALUE_OF_SPLASH          = 1500L

        /* Endless Scrolling View Type */
        const val VIEW_TYPE_ITEM                 = 0
        const val VIEW_TYPE_LOADING              = 1

        /* Intent Extras Key */
        const val EXTRA_KEY_TOKEN                = "token"
        const val EXTRA_KEY_REFRESH_TOKEN        = "refresh_token"

        /* Retrofit REQUEST Body key */
        const val REQUEST_KEY_GRANT_TYPE         = "grant_type"
        const val REQUEST_KEY_REFRESH            = "refresh_token"

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

        /* Best Values And Type */
        const val BEST_BANNER_COUNT              = 10
        const val BEST_TYPE                      = "viewType"
        const val BEST_BANNER_TYPE               = 0
        const val BEST_TITLE_TYPE                = 1
        const val BEST_RV_TYPE                   = 2
        const val BEST_LOADING_TYPE              = 3
        const val BEST_TITLE_VALUE               = "BEST!"

        /* Offset Default Value */
        const val OFFSET_DEFAULT                 = "0"
        const val LIMIT_DEFAULT                  = "20"
        const val OFFSET_DEFAULT_INT             = 0
        const val LIMIT_DEFAULT_INT              = 20

        /* Grade Sort Id */
        const val GRADE_SORT_ID_KEM              = 340
        const val GRADE_SORT_ID_SOCIETY          = 350
        const val GRADE_SORT_ID_SCIENCE          = 360
        const val GRADE_SORT_ID_ETC              = 370

        /* Select Value */
        const val CONTENT_RESPONSE_VALUE_NAME             = 1   //이름순
        const val CONTENT_RESPONSE_VALUE_SUBJECT          = 2   //과목순
        const val CONTENT_RESPONSE_VALUE_AVG              = 3   //평점순
        const val CONTENT_RESPONSE_VALUE_LATEST           = 4   //최신순
        const val CONTENT_RESPONSE_VALUE_VIEWS            = 5   //조회순
        const val CONTENT_RESPONSE_VALUE_ANSWER           = 6   //답변완료순?
        const val CONTENT_RESPONSE_VALUE_RELEVANCE        = 7   //관련순

        /* Home Fragment Tab Title*/
        const val HOME_TAB_TITLE_BEST            = "추천"
        const val HOME_TAB_TITLE_HOT             = "인기"
        const val HOME_TAB_TITLE_KEM             = "국영수"
        const val HOME_TAB_TITLE_SCIENCE         = "과학"
        const val HOME_TAB_TITLE_SOCIETY         = "사회"
        const val HOME_TAB_TITLE_ETC             = "기타"




    }

}