package com.gongmanse.app.data.network.home

import com.gongmanse.app.data.network.BaseService
import com.gongmanse.app.utils.Constants

object VideoService {

    val client: VideoApi = BaseService.getClient(Constants.BASE_DOMAIN).create(VideoApi::class.java)
}