package com.gongmanse.app.utils

import android.net.Uri
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks
import com.google.firebase.dynamiclinks.ktx.dynamicLink
import com.google.firebase.dynamiclinks.ktx.dynamicLinks
import com.google.firebase.ktx.Firebase
import com.kakao.kakaolink.v2.KakaoLinkService
import com.kakao.message.template.*

@Suppress("DEPRECATION")
class DynamicLink {

    companion object {

        private fun getPromotionDeepLink(): Uri {
            // Generate promotion code
            val promotionCode: String = "XktS";
            // https://ted.com/promotion?code=DF3DY1
            // https://gongmanse.page.link/XktS
            return Uri.parse("https://gongmanse.page.link/$promotionCode")
        }

        fun onDynamicLinkClick() {}

        fun createDynamicLink() {
            // [START create_link]
            val dynamicLink = Firebase.dynamicLinks.dynamicLink {
                link = Uri.parse("https://www.gongmanse.com/videopage")
                domainUriPrefix = ""
            }

            // [END create_link]
        }

    }
}