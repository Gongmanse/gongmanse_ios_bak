package com.gongmanse.app.utils

import android.content.Context
import com.google.android.exoplayer2.upstream.ByteArrayDataSource
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.TransferListener

class CustomDataSourceFactory(private val context: Context, private val listener: TransferListener?, private val subtitles: ByteArray): DataSource.Factory {

    override fun createDataSource(): DataSource {
        val dataSource = ByteArrayDataSource(subtitles)
        if (listener != null) dataSource.addTransferListener(listener)
        return dataSource
    }

}