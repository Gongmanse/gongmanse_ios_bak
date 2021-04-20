package com.gongmanse.app.data.network.progress

class ProgressRepository {

    private val progressClient = ProgressService.client

    suspend fun getProgressList(
        subject: Int?,
        grade: String,
        gradeNum: Int,
        offset: Int,
        limit: Int
    ) = progressClient.getProgressList(
        subject,
        grade,
        gradeNum,
        offset,
        limit
    )

    suspend fun getProgressUnits(
        subject: Int?,
        grade: String,
        gradeNum: Int,
    ) = progressClient.getProgressUnits(
        subject,
        grade,
        gradeNum
    )

}