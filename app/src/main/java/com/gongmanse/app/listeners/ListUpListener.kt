package com.gongmanse.app.listeners

import com.gongmanse.app.model.VideoData

interface ListUpListener {
    fun getListData(items : ArrayList<VideoData>)
}