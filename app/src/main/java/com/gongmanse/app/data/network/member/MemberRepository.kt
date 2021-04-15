package com.gongmanse.app.data.network.member

import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences

class MemberRepository {

    private val memberClient = MemberService.client

    suspend fun getProfile() = memberClient.getProfile(Preferences.token)

    suspend fun getToken(username: String, password: String) = memberClient.getToken(Constants.Request.VALUE_TYPE_PASSWORD, username, password)

    suspend fun getRefreshToken(refresh: String) = memberClient.getRefreshToken(Constants.Request.VALUE_TYPE_REFRESH, refresh)

}