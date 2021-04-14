package com.gongmanse.app.data.network.member

import com.gongmanse.app.utils.Preferences

class MemberRepository {

    private val memberClient = MemberService.client

    suspend fun getProfile() = memberClient.getProfile(Preferences.token)

}