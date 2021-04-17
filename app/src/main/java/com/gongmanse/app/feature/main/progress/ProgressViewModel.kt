package com.gongmanse.app.feature.main.progress

import android.util.Log
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.progress.Progress
import com.gongmanse.app.data.model.progress.ProgressBody
import com.gongmanse.app.data.network.progress.ProgressRepository
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.SingleLiveEvent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.*

class ProgressViewModel (private val progressRepository: ProgressRepository) : ViewModel() {

    companion object {
        private val TAG = ProgressViewModel::class.java.simpleName
    }

    private val _currentProgress = SingleLiveEvent<ArrayList<ProgressBody>>()

    val currentProgress: SingleLiveEvent<ArrayList<ProgressBody>>
        get() = _currentProgress


    fun dataClear() {
        _currentProgress.value?.clear()
    }

    // 진도 학습 리스트
    fun loadProgressList(subject: Int?, grade: String, gradeNum: Int, offset: Int) {
        CoroutineScope(Dispatchers.IO).launch {
            progressRepository.getProgressList(subject, grade, gradeNum, offset, Constants.DefaultValue.LIMIT_INT ).let { response ->
                if (response.isSuccessful) {
                    response.body()?.let {
                        currentProgress.postValue(it.progressBody)
                    }
                } else Log.e(TAG, "Failed Network")
            }

        }
    }



}