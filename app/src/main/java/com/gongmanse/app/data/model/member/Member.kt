package com.gongmanse.app.data.model.member

import com.google.gson.annotations.SerializedName

data class Member(
    val header: Header,
    @SerializedName("body") val memberBody: MemberBody
)