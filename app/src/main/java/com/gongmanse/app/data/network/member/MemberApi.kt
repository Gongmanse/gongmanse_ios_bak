package com.gongmanse.app.data.network.member

import com.gongmanse.app.data.model.member.Member
import com.gongmanse.app.data.model.member.Token
import com.gongmanse.app.utils.Constants
import retrofit2.Response
import retrofit2.http.*

interface MemberApi {

    @FormUrlEncoded
    @POST("v1/auth/token")
    suspend fun getToken(
        @Field(Constants.Request.KEY_GRANT_TYPE) type: String,
        @Field(Constants.Request.KEY_USERNAME) username: String,
        @Field(Constants.Request.KEY_PASSWORD) password: String
    ): Response<Token?>

    @FormUrlEncoded
    @POST("v1/auth/token")
    suspend fun getRefreshToken(
        @Field(Constants.Request.KEY_GRANT_TYPE) type: String,
        @Field(Constants.Request.KEY_REFRESH_TOKEN) refreshToken: String
    ): Response<Token?>

    @GET("v3/member/info")
    suspend fun getProfile(
        @Query(Constants.Request.KEY_TOKEN) token: String
    ): Response<Member?>

}