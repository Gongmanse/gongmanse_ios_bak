package com.gongmanse.app.feature.main.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.data.network.home.VideoRepository

class VideoViewModelFactory(private val videoRepository: VideoRepository): ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return modelClass.getConstructor(VideoRepository::class.java).newInstance(videoRepository)
    }

}