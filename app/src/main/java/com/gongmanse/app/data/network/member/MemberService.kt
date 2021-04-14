package com.gongmanse.app.data.network.member

import com.gongmanse.app.data.network.BaseService
import com.gongmanse.app.utils.Constants

object MemberService {

    val client = BaseService.getClient(Constants.BASE_DOMAIN).create(MemberApi::class.java)

}