package com.gongmanse.app.listeners

import com.gongmanse.app.model.ScheduleDescription

interface OnScheduleClickListener {

    fun dateClick(data: List<ScheduleDescription>?,date:String?)
}