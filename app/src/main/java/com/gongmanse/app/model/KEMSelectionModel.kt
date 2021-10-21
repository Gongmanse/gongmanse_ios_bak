package com.gongmanse.app.model

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gongmanse.app.utils.Constants

class KEMSelectionModel: ViewModel() {

    private val _data: MutableLiveData<String> = MutableLiveData()

    val data: LiveData<String>
        get() = _data

    fun changeValue(string: String) {
        _data.postValue(string)
    }

    fun init() {
        _data.postValue(Constants.CONTENT_VALUE_ALL)
    }
}