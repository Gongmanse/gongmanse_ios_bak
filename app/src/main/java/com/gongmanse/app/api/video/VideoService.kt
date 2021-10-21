package com.gongmanse.app.api.video

import com.gongmanse.app.api.BaseService
import com.gongmanse.app.utils.Constants

object VideoService {

    val client: VideoApi = BaseService.getClient(Constants.BASE_DOMAIN).create(VideoApi::class.java)

}