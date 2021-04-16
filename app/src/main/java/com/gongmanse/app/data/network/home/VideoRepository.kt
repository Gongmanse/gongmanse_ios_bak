package com.gongmanse.app.data.network.home

class VideoRepository {

    private val videoClient = VideoService.client

    suspend fun getSubject(subject : Int?, offset : Int?, limit : Int?, sortId : Int?,type : Int?)
            = videoClient.getSubject(subject,offset,limit,sortId,type)
    suspend fun getBanner() = videoClient.getBanner()
    suspend fun getBest(grade : String?, offset : Int?, limit : Int?) = videoClient.getBest(grade,offset,limit)
    suspend fun getHot(subject: String?,offset: Int?,limit: Int?) = videoClient.getHot(subject,offset,limit)
}
