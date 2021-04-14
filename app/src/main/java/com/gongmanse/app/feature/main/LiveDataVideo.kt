package com.gongmanse.app.feature.main

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.video.Body
import com.gongmanse.app.data.network.RetrofitClient
import com.gongmanse.app.utils.Constants
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Suppress("DEPRECATION")
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
    //과목별
    fun loadVideo(subject : Int?, offset : Int?, limit : Int?, sortId : Int?){
//        Log.d("TAG", "$subject : $offset : $limit : $sortId ")
        CoroutineScope(Dispatchers.IO).launch {
            RetrofitClient.getService().getSubject(subject, offset, limit, sortId).execute().apply {
                if (this.isSuccessful) {
//                    Log.d("TAG", "${this.body()}")
                    this.body()?.let { response ->
                        response.header.totalRows.let {_totalValue.postValue(it.toInt())}
                        response.body.let {
                            _currentValue.postValue(it)
                        }
                    }
                }
            }
        }
    }
    //시리즈
    fun loadSeries(subject : Int?, offset : Int?, limit : Int?, sortId : Int?){
        CoroutineScope(Dispatchers.IO).launch {
            //Todo getApi 변경 (시리즈 나오면)
            RetrofitClient.getService().getSubject(subject, offset, limit, sortId).execute().apply {
                if (this.isSuccessful) {
                    this.body()?.let { response ->
                              response.header.totalRows.let {_totalValue.postValue(it.toInt())}
                       response.body.let {
                           _currentValue.postValue(it)
                       }
                    }
                }
            }
        }
    }
    // 배너
    fun loadVideo(){
        CoroutineScope(Dispatchers.IO).launch {
            //Todo getApi 변경 (시리즈 나오면)
            RetrofitClient.getService().getBanner().execute().apply {
                if (this.isSuccessful) {
                    this.body()?.let { response ->
                        response.header.totalRows.let {_totalValue.postValue(it.toInt())}
                        response.body.let {
                            _currentValue.postValue(it)
                        }
                    }
                }
            }
        }
    }
    //추천
    fun loadVideo(grade : String?,offset : Int?, limit : Int?){
        CoroutineScope(Dispatchers.IO).launch {
            //Todo getApi 변경 (시리즈 나오면)
            var sGrade = grade
            if(grade == null){
                sGrade = Constants.SelectValue.SORT_ALL_GRADE_SERVER
            }
            RetrofitClient.getService().getBest(sGrade, offset, limit).execute().apply {
                if (this.isSuccessful) {
                    this.body()?.let { response ->
                        var isMore = true
                        response.body.let {
                            _currentValue.postValue(it)
                        }
                        response.header.totalRows.let {_totalValue.postValue(it.toInt())}
                        isMore = response.header.isMore.toBoolean()
                    }
                }
            }
        }
    }

}

