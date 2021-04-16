package com.gongmanse.app.utils

import android.icu.text.CaseMap

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

    /* Init Value */
    class Init {
        companion object {
            const val INIT_STRING = ""
            const val INIT_INT    = 0
        }
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
            const val KEY_TOKEN                 = "token"
            const val KEY_GRANT_TYPE            = "grant_type"
            const val KEY_REFRESH_TOKEN         = "refresh_token"
            const val KEY_USERNAME              = "usr"
            const val KEY_PASSWORD              = "pwd"
            const val KEY_SUBJECT               = "subject"
            const val KEY_GRADE                 = "grade"
            const val KEY_GRADE_NUM             = "gradeNum"
            const val KEY_OFFSET                = "offset"
            const val KEY_LIMIT                 = "limit"

            const val VALUE_TYPE_PASSWORD       = "password"
            const val VALUE_TYPE_REFRESH        = "refresh_token"
            const val VALUE_TYPE_SUBJECT        = "subject"
            const val VALUE_TYPE_GRADE          = "grade"
            const val VALUE_TYPE_GRADE_NUM      = "gradeNum"

        }
    }

    // Retrofit RESPONSE Body key
    class Response {
        companion object {
            const val KEY_BODY   = "body"
            const val KEY_HEADER = "header"
        }
    }

    class ViewType {
        companion object {
            const val DEFAULT                   = 0
            const val LOADING                   = 1
            const val BANNER                    = 2
            const val SERIES                    = 3
            const val NOTE                      = 4
            const val TITLE                     = 5
        }
    }

    class SelectValue{
        companion object {
            const val SORT_ALL                          = "전체보기"
            const val SORT_ALL_GRADE_SERVER             = "전체"
            const val SORT_ALL_GRADE_NULL               = "모든"
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

    class Fragment {
        companion object {
            const val TYPE_PROGRESS                     = "진도학습"
            const val TYPE_SEARCH                       = "검색"
            const val TYPE_COUNSEL                      = "전문가상담"
            const val TYPE_TEACHER                      = "강사별강의"
        }
    }

    class BestValue{
        companion object {
            const val BANNER_COUNT                      = 10
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

    class SubjectValue{
        companion object {
            const val KEM                               = 34
            const val SOCIETY                           = 35
            const val SCIENCE                           = 36
            const val ETC                               = 37
        }
    }

    class SubjectType{
        companion object {
            const val DEFAULT                           = 0
            const val PROBLEM                           = 1
            const val SERIES                            = 2
            const val NOTE                              = 3
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

    class Teacher{
        companion object {
            const val TAB_TITLE_ELEMENTARY       = "초등"
            const val TAB_TITLE_MIDDLE           = "중등"
            const val TAB_TITLE_HIGH             = "고등"
        }
    }


    class Progress{
        companion object {
            const val TAB_TITLE_KEM         = "국영수"
            const val TAB_TITLE_SCIENCE     = "과학"
            const val TAB_TITLE_SOCIETY     = "사회"
            const val TAB_TITLE_ETC         = "기타과목"

            const val VALUE_ELEMENTARY_VIEW  = '초'
            const val VALUE_MIDDLE_VIEW      = '중'
            const val VALUE_HIGH_VIEW        = '고'
        }
    }

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

    //    class Name{
//        companion object {
//
//        }
//    }

}