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
            const val KEY_TOKEN = "token"
            const val KEY_GRANT_TYPE = "grant_type"
            const val KEY_REFRESH_TOKEN = "refresh_token"

        }
    }
    class Endless {
        companion object {
            const val VIEW_TYPE_ITEM                    = 0
            const val VIEW_TYPE_LOADING                 = 1
        }
    }

    class SelectValue{
        companion object {
            const val SORT_ALL                          = "전체보기"
            const val SORT_ALL_GRADE_SERVER             = "전체"
            const val SORT_SERIES                       = "시리즈보기"
            const val SORT_PROBLEM                      = "문제풀이"
            const val SORT_NOTE                         = "노트보기"
            const val SORT_ALL_GRADE                    = "모든 학년"
            const val SORT_ALL_UNIT                     = "모든 단원"
            const val SORT_ALL_SUBJECT                  = "모든 과목"
            const val SORT_AVG                          = "평점순"
            const val SORT_LATEST                       = "최신순"
            const val SORT_NAME                         = "이름순"
            const val SORT_SUBJECT                      = "과목순"
            const val SORT_VIEWS                        = "조회순"
            const val SORT_RELEVANCE                    = "관련순"
            const val SORT_ANSWER                       = "답변 완료순"
            const val SORT_VALUE_NAME                   = 1   //이름순
            const val SORT_VALUE_SUBJECT                = 2   //과목순
            const val SORT_VALUE_AVG                    = 3   //평점순
            const val SORT_VALUE_LATEST                 = 4   //최신순
            const val SORT_VALUE_VIEWS                  = 5   //조회순
            const val SORT_VALUE_ANSWER                 = 6   //답변완료순?
            const val SORT_VALUE_RELEVANCE              = 7   //관련순
        }
    }

    class BestValue{
        companion object {
            const val BANNER_COUNT                      = 10
            const val TYPE                              = "viewType"
            const val BANNER_TYPE                       = 2
            const val TITLE_TYPE                        = 3
            const val RV_TYPE                           = 4
            const val LOADING_TYPE                      = 5
            const val TITLE_VALUE                       = "BEST!"
        }
    }

    class DefaultValue{
        companion object {
            const val OFFSET                            = "0"
            const val LIMIT                             = "20"
            const val OFFSET_INT                        = 0
            const val LIMIT_INT                         = 20
        }
    }

    class GradeValue{
        companion object {
            const val KEM                               = 340
            const val SOCIETY                           = 350
            const val SCIENCE                           = 360
            const val ETC                               = 370
            const val KEM_PROBLEM                       = 341
            const val SOCIETY_PROBLEM                   = 351
            const val SCIENCE_PROBLEM                   = 361
            const val ETC_PROBLEM                       = 371
        }
    }


    class GradeType{
        companion object {
            const val ELEMENTARY       = "초등"
            const val ELEMENTARY_VIEW  = "초"
            const val MIDDLE           = "중등"
            const val MIDDLE_VIEW      = "중"
            const val HIGH             = "고등"
            const val HIGH_VIEW        = "고"
        }
    }

    class Home{
        companion object {
            const val TAB_TITLE_BEST                    = "추천"
            const val TAB_TITLE_HOT                     = "인기"
            const val TAB_TITLE_KEM                     = "국영수"
            const val TAB_TITLE_SCIENCE                 = "과학"
            const val TAB_TITLE_SOCIETY                 = "사회"
            const val TAB_TITLE_ETC                     = "기타"
        }
    }

    class Progress{
        companion object {
            const val TAB_TITLE_KEM         = "국영수"
            const val TAB_TITLE_SCIENCE     = "과학"
            const val TAB_TITLE_SOCIETY     = "사회"
            const val TAB_TITLE_ETC         = "기타과목"
        }
    }

//    class Name{
//        companion object {
//
//        }
//    }

    // Action
    class Action {
        companion object {
            const val VIEW_LOGIN               = 0
            const val VIEW_SIGN_UP             = 1
            const val VIEW_NOTIFICATION        = 2
            const val VIEW_EDIT_PROFILE        = 3
            const val VIEW_PASS_TICKET         = 4
        }
    }

}