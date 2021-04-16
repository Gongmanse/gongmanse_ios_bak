package com.gongmanse.app.feature.main.progress

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.data.network.progress.ProgressRepository

class ProgressViewModelFactory(private val progressRepository: ProgressRepository): ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return modelClass.getConstructor(ProgressRepository::class.java).newInstance(progressRepository)
    }
}