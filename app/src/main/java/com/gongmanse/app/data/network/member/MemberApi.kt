package com.gongmanse.app.data.network.member

import com.gongmanse.app.data.model.member.Member
import com.gongmanse.app.utils.Constants
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Query

interface MemberApi {

    @GET("v3/member/info")
    suspend fun getProfile(
        @Query(Constants.Request.KEY_TOKEN) token: String
    ): Response<Member>

}