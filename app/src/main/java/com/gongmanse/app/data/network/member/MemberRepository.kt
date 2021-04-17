package com.gongmanse.app.data.network.member

import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences

class MemberRepository {

    private val client = MemberService.client

    suspend fun getProfile() = client.getProfile(Preferences.token)

//    suspend fun setProfile(nickname: String, email: String) = client

    suspend fun getToken(username: String, password: String) = client.getToken(Constants.Request.VALUE_TYPE_PASSWORD, username, password)

    suspend fun getToken(refresh: String) = client.getToken(Constants.Request.VALUE_TYPE_REFRESH, refresh)

}