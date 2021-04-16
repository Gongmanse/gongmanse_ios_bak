package com.gongmanse.app.feature.main.counsel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.data.network.counsel.CounselRepository

class CounselViewModelFactory(private val counselRepository: CounselRepository): ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return modelClass.getConstructor(CounselRepository::class.java).newInstance(counselRepository)
    }

}