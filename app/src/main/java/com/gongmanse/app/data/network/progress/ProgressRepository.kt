package com.gongmanse.app.data.network.progress

class ProgressRepository {

    private val progressClient = ProgressService.client

    suspend fun getProgressList() = progressClient
}