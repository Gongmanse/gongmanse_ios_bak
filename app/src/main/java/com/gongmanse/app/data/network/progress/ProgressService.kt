package com.gongmanse.app.data.network.progress

import com.gongmanse.app.data.network.BaseService
import com.gongmanse.app.utils.Constants

object ProgressService {
    val client: ProgressApi = BaseService.getClient(Constants.BASE_DOMAIN).create(ProgressApi::class.java)
}