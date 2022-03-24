package com.gongmanse.app.model

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gongmanse.app.R
import com.gongmanse.app.activities.LoginActivity
import com.gongmanse.app.api.video.VideoRepository
import com.gongmanse.app.utils.*
import com.gongmanse.app.utils.Event
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.jetbrains.anko.*

class VideoViewModel(private val videoRepository: VideoRepository?): ViewModel() {

    private val _showLoginToast = MutableLiveData<Event<Boolean>>()
    private val _showToast = MutableLiveData<Event<String>>()
    private val _showQNAToast = MutableLiveData<Event<Boolean>>()
    private val _moveActivity = MutableLiveData<Event<Boolean>>()
    private val _moveCommentary = MutableLiveData<Event<Boolean>>()

    private val _data = SingleLiveEvent<VideoData>()
    private val _playList = SingleLiveEvent<VideoList>()
    private val _currentQNAData = SingleLiveEvent<ArrayList<QNAData>>()
    private val _currentNoteData = SingleLiveEvent<NoteCanvasData>()
    private val _bookmark = SingleLiveEvent<Boolean>()

    private val _rating = SingleLiveEvent<String>()
    private val _userRating = SingleLiveEvent<String>()
    private val _useRating = SingleLiveEvent<Boolean>()

    val showLoginToast: LiveData<Event<Boolean>> = _showLoginToast

    val showToast: LiveData<Event<String>> = _showToast

    val showQNAToast: LiveData<Event<Boolean>> = _showQNAToast

    val moveActivity: LiveData<Event<Boolean>> = _moveActivity

    val moveCommentary: LiveData<Event<Boolean>> = _moveCommentary

    val data: SingleLiveEvent<VideoData>
        get() = _data

    val playList: SingleLiveEvent<VideoList>
        get() = _playList

    val currentQNAData: SingleLiveEvent<ArrayList<QNAData>>
        get() = _currentQNAData

    val currentNoteData: SingleLiveEvent<NoteCanvasData>
        get() = _currentNoteData

    val bookmark: SingleLiveEvent<Boolean>
        get() = _bookmark

    val rating: SingleLiveEvent<String>
        get() = _rating

    val userRating: SingleLiveEvent<String>
        get() = _userRating

    val useRating: SingleLiveEvent<Boolean>
        get() = _useRating

    // offset
    val offsetQNA = SingleLiveEvent<String?>()
    val qnaOffset = SingleLiveEvent<String?>()
    val offsetJindo = SingleLiveEvent<String?>()

    val bottomVideoId = SingleLiveEvent<String?>()
    val bottomURL = SingleLiveEvent<String?>()
    val bottomPosition = SingleLiveEvent<Long?>()
    val bottomTitle = SingleLiveEvent<String?>()
    val bottomTeacherName = SingleLiveEvent<String?>()
    val bottomSeriesId = SingleLiveEvent<String?>()
    val bottomSubjectId = SingleLiveEvent<Int?>()
    val bottomGrade = SingleLiveEvent<String?>()
    val bottomKeyword = SingleLiveEvent<String?>()
    val bottomQueryType = SingleLiveEvent<Int?>()
    var bottomNowPosition = SingleLiveEvent<Int?>()
    var bottomSorting = SingleLiveEvent<Int?>()

    val videoId = SingleLiveEvent<String>()
    val seriesId = SingleLiveEvent<String?>()
    val sorting = SingleLiveEvent<Int>()

    // Search
    val subjectId = SingleLiveEvent<Int?>()
    val grade = SingleLiveEvent<String?>()
    val keyword = SingleLiveEvent<String?>()

    // jindoId
    val jindoId = SingleLiveEvent<Int?>()

    // 나의 활동: 강의Q&A
    val etQuestion    = SingleLiveEvent<String?>()        // 입력한 질문


    val hashTag = SingleLiveEvent<String>()

    val playListNowPosition = SingleLiveEvent<Int>()
    val playListOffset = SingleLiveEvent<Int>()
    val playListType = SingleLiveEvent<Int>()

    // 자막 출력 여부
    val useCaption = SingleLiveEvent<Boolean>()
    // 아웃트로 컨트롤러 출력 여부
    val useOutro = SingleLiveEvent<Boolean>()
    // 영상 모드 (인트로, 강의 영상, 아웃트로)
    val videoMode = SingleLiveEvent<Int>()

    init {
        useCaption.value = false
        useOutro.value = false
        videoMode.value = Constants.VIDEO_INTRO
        playListNowPosition.value = 0

        offsetQNA.postValue(Constants.OFFSET_DEFAULT)
        etQuestion.postValue(null)

        bookmark.postValue(false)
    }

    fun load() {
        CoroutineScope(Dispatchers.IO).launch {
            videoRepository?.getVideoData(videoId.value)?.let { response ->
                GBLog.e(TAG, "load(): result code => ${response.code()}")
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        body.data?.let { videoData ->
                            _data.postValue(videoData)
                            _bookmark.postValue(videoData.bookmarks)
                            _rating.postValue((videoData.rating ?: "0").toFloat().toString())
                            _userRating.postValue((videoData.userRate ?: "0").toFloat().toString())
                            _useRating.postValue(videoData.userRate != null)
                        }
                    }
                }
            }
        }
    }

    fun loadBest() {
        CoroutineScope(Dispatchers.IO).launch {
            videoRepository?.getBestVideoData(videoId.value)?.let { response ->
                GBLog.v(TAG, "loadBest(): result code => ${response.code()}")
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        body.data?.let { videoData ->
                            _data.postValue(videoData)
                            _bookmark.postValue(videoData.bookmarks)
                            _rating.postValue(videoData.rating?.toFloat().toString())
                            _useRating.postValue(videoData.userRate != null)
                        }
                    }
                }
            }
        }
    }

    fun loadPlayList() {
        CoroutineScope(Dispatchers.IO).launch {
            Log.v(TAG, "loadPlayList(): type => ${playListType.value}")
            Log.v(TAG, "loadPlayList(): subjectId => ${subjectId.value}")
            Log.v(TAG, "loadPlayList(): grade => ${grade.value}")
            Log.v(TAG, "loadPlayList(): keyword => ${keyword.value}")
            Log.v(TAG, "loadPlayList(): sorting => ${sorting.value}")
            Log.v(TAG, "loadPlayList(): playListOffset => ${playListOffset.value}")
            Log.v(TAG, "loadPlayList(): playListNowPosition => ${playListNowPosition.value}")
            videoRepository?.getPlayList(playListType.value
                                        , seriesId.value
                                        , jindoId.value
                                        , sorting.value
                                        , subjectId.value
                                        , grade.value
                                        , keyword.value
                                        , playListOffset.value
                                        , playListNowPosition.value?.div(20)?.plus(1)?.times(20)
            )?.let { response ->
                Log.v(TAG, "result code => ${response.code()}")
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        Log.v(TAG, "body => $body")
                        _playList.postValue(body)
                    }
                } else Log.e(TAG,"response result code:${response.code()}, error:${response.errorBody()}, message:${response.message()}")
            }
        }
    }

    fun getNowPosition() {
        CoroutineScope(Dispatchers.IO).launch {
            Log.v(TAG, "getNowPosition(): position => ${playListNowPosition.value}")
            videoRepository?.getNowPosition(seriesId.value, videoId.value)?.let { response ->
                Log.v(TAG, "result code => ${response.code()}")
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        Log.v(TAG, "body => $body")
                        playListNowPosition.postValue(body.data?.num)
                        Handler(Looper.getMainLooper()).postDelayed({
                            loadPlayList()
                        }, 300L)
                    }
                }
            }
        }
    }

    private fun getNowPosition2() {
        CoroutineScope(Dispatchers.IO).launch {
            Log.v(TAG, "getNowPosition2(): position => ${playListNowPosition.value}")
            Log.v(TAG, "getNowPosition2(): seriesId => ${seriesId.value}")
            Log.v(TAG, "getNowPosition2(): videoId => ${videoId.value}")
            videoRepository?.getNowPosition(seriesId.value, videoId.value)?.let { response ->
                Log.v(TAG, "result code => ${response.code()}")
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        Log.v(TAG, "body => $body")
                        playListNowPosition.postValue(body.data?.num)
                    }
                }
            }
        }
    }

    fun setBookMark() {
        if (Preferences.token.isEmpty()) {
            onLoginCall()
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                Log.v(TAG, "setBookMark(): bookmark => ${_bookmark.value}")
                if (_bookmark.value == true) {
                    videoRepository?.removeBookMark(videoId.value)?.let { response ->
                        if (response.isSuccessful) {
                            _bookmark.postValue(false)
                            _showToast.postValue(Event("즐겨찾기가 취소되었습니다."))
                        }
                    }
                } else {
                    videoRepository?.addBookMark(videoId.value)?.let { response ->
                        if (response.isSuccessful) {
                            _bookmark.postValue(true)
                            _showToast.postValue(Event("즐겨찾기가 등록되었습니다."))
                        }
                    }
                }
            }
        }
    }

    fun setUserRating(r: Int) {
        CoroutineScope(Dispatchers.IO).launch {
            Log.v(TAG, "setUserRating(): rating => $r")
            videoRepository?.addRating(videoId.value, r)?.let { response ->
                Log.v(TAG, "result code => ${response.code()}")
                if (response.isSuccessful) {
                    _showToast.postValue(Event("평점이 적용되었습니다."))
                }
            }
        }
    }

    // 동영상 강의: Q&A 내용
    fun getQNAContents() {
        CoroutineScope(Dispatchers.IO).launch {
            Log.v(TAG, "getQNAContents(): videoId => ${videoId.value}, offsetQNA:${offsetQNA.value}")
            videoRepository?.getQNAContents(videoId.value, offsetQNA.value?.toInt())?.let { response ->
                if (response.isSuccessful) {
                    Log.e(TAG,"response.code() => ${response.code()} : ${response.message()} : getQNAContents videoId => ${videoId.value}")
                    response.body()?.let { body ->
                        Log.e(TAG,"getQNAContents body => $body")
                        currentQNAData.postValue(body.data)
                    }
                } else Log.e(TAG, "getQNAContents Failed Network")
            }
        }
    }

    fun clear() {
        currentNoteData.postValue(null)
    }

    fun initNoteData(videoId: String?){
        Log.d("VideoNoteFragment1@@", "initNoteData()....@@@")
        clear()
        if(Preferences.token.isEmpty()) {
            CoroutineScope(Dispatchers.IO).launch {
                videoRepository?.getGuestNoteInfo(videoId)?.let { response ->
                    if (response.isSuccessful) {
                        response.body()?.let {
                            currentNoteData.postValue(it)
                        }
                    } else Log.e(TAG, "Failed Network")
                }
            }
        }else{
            CoroutineScope(Dispatchers.IO).launch {
                videoRepository?.getNoteInfo(videoId)?.let { response ->
                    Log.d("response ->" ,"response ->$response")
                    if (response.isSuccessful) {
                        response.body()?.let { body ->
                            body.data.let {
                                currentNoteData.postValue(it)
                            }
                        }
                    } else Log.e(TAG, "Failed Network")
                }
            }
        }
    }

    fun uploadNote(context: Context,videoId: String?, getPaint : ArrayList<NoteStroke> ) {
        if (Preferences.token.isEmpty()) {
            context.apply {
                alert(message = resources.getString(R.string.content_text_would_you_like_to_login)) {
                    yesButton {startActivity(intentFor<LoginActivity>().singleTop()) }
                    noButton { dialog -> dialog.dismiss() }
                }.show()
            }
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                val g = Gson()
                val sJson = g.toJson(NoteJson(Constants.ASPECT_RATIO, getPaint))
                videoRepository?.uploadNoteInfo(videoId,sJson)?.let { response ->
                    if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                    if (response.isSuccessful) {
                        withContext(Dispatchers.Main){
                            context.toast("업로드 완료")
                        }
                    }
                }
            }
        }
    }

    // 문제풀이, 개념강의로 이동
    fun goCommentary() {
        if (Preferences.token.isEmpty()) {
            onLoginCall()
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                videoRepository?.getVideoData(data.value?.commentaryId)?.let { response ->
                    Log.v(TAG, "goCommentary(): result code => ${response.code()}")
                    if (response.isSuccessful) {
                        response.body()?.let { body ->
                            body.data?.let { videoData ->
                                Log.v(TAG, "videoData => $videoData")
                                seriesId.postValue(videoData.seriesId)
                                videoId.postValue(videoData.videoId ?: videoData.id ?: "0")
                                playListType.postValue(Constants.QUERY_TYPE_SERIES)
                                getNowPosition2()
                                _moveCommentary.postValue(Event(videoData.hasCommentary == 1))
                            }
                        }
                    }
                }
            }
        }
    }

    private fun onLoginCall() {
        _showLoginToast.value = Event(true)
    }

    fun moveSeriesList(){
        Log.v(TAG, "moveSeriesList => ${seriesId.value}")
        if(seriesId.value.isNullOrEmpty() || seriesId.value == "null" || seriesId.value == "0"){
            Log.v(TAG, "moveSeriesList => ${seriesId.value} : if")
            _showToast.postValue(Event("관련 시리즈가 없습니다."))
        }else{
            Log.v(TAG, "moveSeriesList => ${seriesId.value} : else")
            _moveActivity.value = Event(true)
        }

    }

    fun addQNAComment() {
        if (Preferences.token.isEmpty()) {
            onLoginCall()
        } else if (etQuestion.value.isNullOrEmpty() || etQuestion.value?.isBlank() == true) {
            _showToast.value = Event("질문을 입력해 주세요.")
        } else {
            CoroutineScope(Dispatchers.IO).launch {
                videoRepository?.addQNAContents(videoId.value, etQuestion.value)?.let { response ->
                    if (response.isSuccessful) {
                        _showQNAToast.postValue(Event(true))
                    }
                }
            }
        }
    }

    companion object {
        private val TAG = VideoViewModel::class.java.simpleName
    }

}