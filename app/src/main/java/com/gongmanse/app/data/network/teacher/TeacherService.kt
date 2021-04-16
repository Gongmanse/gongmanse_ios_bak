package com.gongmanse.app.data.network.teacher

import com.gongmanse.app.data.network.BaseService
import com.gongmanse.app.utils.Constants

object TeacherService {

    val client: TeacherApi = BaseService.getClient(Constants.BASE_DOMAIN).create(TeacherApi::class.java)
}
