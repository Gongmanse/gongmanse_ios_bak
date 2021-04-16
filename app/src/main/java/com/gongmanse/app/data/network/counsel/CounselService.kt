package com.gongmanse.app.data.network.counsel

import com.gongmanse.app.data.network.BaseService
import com.gongmanse.app.utils.Constants

object CounselService {

    val client: CounselApi = BaseService.getClient(Constants.BASE_DOMAIN).create(CounselApi::class.java)
}