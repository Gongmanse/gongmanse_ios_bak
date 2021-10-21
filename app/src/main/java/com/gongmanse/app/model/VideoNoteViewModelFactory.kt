package com.gongmanse.app.model

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.api.video.VideoRepository

class VideoNoteViewModelFactory(private val repository: VideoRepository) : ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return modelClass.getConstructor(VideoRepository::class.java).newInstance(repository)
    }
}