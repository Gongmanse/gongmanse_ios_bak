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

}