package com.gongmanse.app.feature.main.progress

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.progress.ProgressBody
import com.gongmanse.app.data.network.progress.ProgressRepository
import java.util.ArrayList

class ProgressViewModel (private val progressRepository: ProgressRepository) : ViewModel() {

    private val _currentProgress = MutableLiveData<ArrayList<ProgressBody>>()

}