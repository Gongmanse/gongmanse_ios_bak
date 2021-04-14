package com.gongmanse.app.data.model.member

data class MemberBody(
    val PremiumActivateDate: String,
    val email: String,
    val name: String,
    val nickname: String,
    val premiumExpireDate: String,
    val profile: String,
    val registrationDate: String,
    val type: String,
    val userId: String,
    val username: String
)