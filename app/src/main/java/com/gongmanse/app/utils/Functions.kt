package com.gongmanse.app.utils

import com.gongmanse.app.data.model.member.MemberBody

object Functions {

    /* User eType */
    private const val USER_TYPE_SUPER_ADMIN  = "Super Admin"
    private const val USER_TYPE_ADMIN        = "Admin"
    private const val USER_TYPE_MEMBER       = "Member"
    private const val USER_TYPE_PROFESSIONAL = "Professional"

    fun getGradeDescription(body: MemberBody?): String {
        if (body == null) return "로그인하고 더많은 서비스를 누리세요."
        return when (body.type) {
            USER_TYPE_SUPER_ADMIN -> "${body.nickname}님은 관리자 회원입니다."
            USER_TYPE_ADMIN -> "${body.nickname}님은 매니저 회원입니다."
            USER_TYPE_MEMBER -> "${body.nickname}님은 일반 회원입니다."
            USER_TYPE_PROFESSIONAL -> "${body.nickname}님은 숙련자 회원입니다."
            else -> "로그인하고 더많은 서비스를 누리세요."
        }
    }

}