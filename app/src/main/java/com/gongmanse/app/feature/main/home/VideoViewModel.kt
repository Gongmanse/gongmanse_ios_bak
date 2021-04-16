package com.gongmanse.app.feature.main.home


import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.video.VideoBody
import com.gongmanse.app.data.network.home.VideoRepository
import com.gongmanse.app.utils.Constants
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class VideoViewModel(private val videoRepository: VideoRepository) : ViewModel() {

    private val _currentValue = MutableLiveData<ArrayList<VideoBody>>()
    private val _currentBannerValue = MutableLiveData<ArrayList<VideoBody>>()
    private val _totalValue = MutableLiveData<Int>()
    val currentValue : LiveData<ArrayList<VideoBody>>
        get() = _currentValue
    val totalValue : LiveData<Int>
        get() = _totalValue
    val currentBannerValue : LiveData<ArrayList<VideoBody>>
        get() = _currentBannerValue

    fun liveDataClear(){
        _currentValue.value?.clear()
    }
    //과목별
    fun loadVideo(subject : Int?, offset : Int?, limit : Int?, sortId : Int?,type : Int?){
//        Log.d("TAG", "$subject : $offset : $limit : $sortId ")
        CoroutineScope(Dispatchers.IO).launch {
            try {
                videoRepository.getSubject(subject, offset, limit, sortId, type).apply {
                    if (this.isSuccessful) {
//                    Log.d("TAG", "${this.body()}")
                        this.body()?.let { response ->
                            response.videoHeader.totalRows.let {_totalValue.postValue(it.toInt())}
                            response.videoBody.let {
                                _currentValue.postValue(it)
                            }
                        }
                    }
                }
            }catch (e : Exception){
                Log.e("error" , "$e")
            }
        }
    }
    // 배너
    fun loadBanner(){
        CoroutineScope(Dispatchers.IO).launch {
            try {
                videoRepository.getBanner().apply {
                    if (this.isSuccessful) {
                        this.body()?.let { response ->
                            response.videoHeader.totalRows.let {_totalValue.postValue(it.toInt())}
                            response.videoBody.let {
                                _currentBannerValue.postValue(it)
                            }
                        }
                    }
                }
            }catch (e : Exception){
                Log.e("error" , "$e")
            }
        }
    }
    //추천
    fun loadBest(grade : String?,offset : Int?, limit : Int?){
        CoroutineScope(Dispatchers.IO).launch {
            //Todo getApi 변경 (시리즈 나오면)
            var sGrade = grade
            if(grade == null){
                sGrade = Constants.SelectValue.SORT_ALL_GRADE_NULL
            }
            videoRepository.getBest(sGrade, offset, limit).apply {
                if (this.isSuccessful) {
                    this.body()?.let { response ->
                        response.videoBody.let {
                            _currentValue.postValue(it)
                        }
                        response.videoHeader.totalRows.let {_totalValue.postValue(it.toInt())}
                    }
                }
            }
        }
    }
    // 인기
    fun loadHot(grade : String?,offset : Int?, limit : Int?){
        CoroutineScope(Dispatchers.IO).launch {
            //Todo getApi 변경 (시리즈 나오면)
            var sGrade = grade
            if(grade == null){
                sGrade = Constants.SelectValue.SORT_ALL_GRADE_NULL
            }
            videoRepository.getHot(sGrade, offset, limit).apply {
                if (this.isSuccessful) {
                    this.body()?.let { response ->
                        response.videoBody.let {
                            _currentValue.postValue(it)
                        }
                        response.videoHeader.totalRows.let {_totalValue.postValue(it.toInt())}
                    }
                }
            }
        }
    }
}

