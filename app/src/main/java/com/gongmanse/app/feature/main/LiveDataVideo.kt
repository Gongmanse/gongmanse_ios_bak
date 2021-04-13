package com.gongmanse.app.feature.main

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.Body
import com.gongmanse.app.data.network.RetrofitClient
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class LiveDataVideo : ViewModel() {

    private val _currentValue = MutableLiveData<ArrayList<Body>>()
    private val _totalValue = MutableLiveData<Int>()
    val currentValue : LiveData<ArrayList<Body>>
        get() = _currentValue
    val totalValue : LiveData<Int>
        get() = _totalValue

    fun liveDataClear(){
        _currentValue.value?.clear()
    }
    fun loadVideo(subject : Int?, offset : Int?, limit : Int?, sortId : Int?){
        CoroutineScope(Dispatchers.IO).launch {
            RetrofitClient.getService().getSubject(subject, offset, limit, sortId).execute().apply {
                if (this.isSuccessful) {
                    this.body()?.let { response ->
                        response.header.totalRows.let {_totalValue.postValue(it.toInt())}
                        response.body.let {
                            _currentValue.postValue(it as ArrayList<Body>)
                        }
                    }
                }
            }
        }
    }
    fun loadSeries(subject : Int?, offset : Int?, limit : Int?, sortId : Int?){
        CoroutineScope(Dispatchers.IO).launch {
            //Todo getApi 변경 (시리즈 나오면)
            RetrofitClient.getService().getSubject(subject, offset, limit, sortId).execute().apply {
                if (this.isSuccessful) {
                    this.body()?.let { response ->
                              response.header.totalRows.let {_totalValue.postValue(it.toInt())}
                       response.body.let {
                           _currentValue.postValue(it as ArrayList<Body>)
                       }
                    }
                }
            }
        }
    }

}

