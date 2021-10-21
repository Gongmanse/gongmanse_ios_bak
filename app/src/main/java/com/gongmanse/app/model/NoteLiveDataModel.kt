package com.gongmanse.app.model

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

enum class ActionType {
    SET,CLEAR
}

class NoteLiveDataModel : ViewModel() {

    private val _currentValue = MutableLiveData<ArrayList<VideoData>>()
    private val _currentPosition = MutableLiveData<Int>()
    private val _currentType = MutableLiveData<Int>()

    val currentValue : LiveData<ArrayList<VideoData>>
        get() = _currentValue
    val currentPosition : LiveData<Int>
        get() = _currentPosition
    val currentType : LiveData<Int>
        get() = _currentType

    fun updateValue(actionType: ActionType,input: ArrayList<VideoData>,position : Int,type : Int){
        when(actionType){
            ActionType.SET ->{
                _currentValue.value = input
                _currentPosition.value = position
                _currentType.value = type
            }
            ActionType.CLEAR ->{
                _currentValue.value?.clear()
                _currentPosition.value = -1
                _currentType.value = -1
            }

        }
    }

}

