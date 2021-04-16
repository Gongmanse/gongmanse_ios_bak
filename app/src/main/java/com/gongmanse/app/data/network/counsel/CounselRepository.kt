package com.gongmanse.app.data.network.counsel

class CounselRepository {

    private val counselClient = CounselService.client

    suspend fun getSubject(subject : String?, offset : Int?, limit : Int?)
            = counselClient.getSubject(subject,offset,limit)

}
