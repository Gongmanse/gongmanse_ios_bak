package com.gongmanse.app.utils

class Constants {

    companion object {

        /* Server API IP */
        const val BASE_DOMAIN                    = "https://api.gongmanse.com"
        const val FILE_DOMAIN                    = "https://file.gongmanse.com"
        const val WEB_VIEW_DOMAIN                = "https://webview.gongmanse.com"
        const val NOTICE_EVENT_VALUE_DOMAIN      = "https://webview.gongmanse.com/events/view/"
        const val PRIVACY_POLICY_DOMAIN          = "/users/privacy_policy"
        const val TERMS_OF_SERVICE_DOMAIN        = "/users/toa_read"

        /* Delay Value */
        const val DELAY_VALUE_OF_ENDLESS         = 1500L
        const val DELAY_VALUE_OF_SPLASH          = 1500L

        /* Intent Extras Key */
        const val EXTRA_KEY_TOKEN                = "token"
        const val EXTRA_KEY_REFRESH_TOKEN        = "refresh_token"

        /* Retrofit REQUEST Body key */
        const val REQUEST_KEY_GRANT_TYPE         = "grant_type"
        const val REQUEST_KEY_REFRESH            = "refresh_token"




    }

}