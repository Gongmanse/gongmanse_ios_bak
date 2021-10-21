package com.gongmanse.app.model

import android.content.Context
import android.util.Log
import androidx.annotation.MainThread
import androidx.lifecycle.ViewModel
import com.gongmanse.app.R
import com.gongmanse.app.activities.LoginActivity
import com.gongmanse.app.api.video.VideoRepository
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import com.gongmanse.app.utils.SingleLiveEvent
import com.google.gson.Gson
import kotlinx.coroutines.*
import org.jetbrains.anko.*

class VideoNoteViewModel(private val videoRepository: VideoRepository?): ViewModel() {

//    companion object {
//        private val TAG = VideoNoteViewModel::class.java.simpleName
//    }
//
//
//    private val _currentNoteData = SingleLiveEvent<NoteCanvasData>()
//
//    val currentNoteData: SingleLiveEvent<NoteCanvasData>
//        get() = _currentNoteData

//    fun initNoteData(videoId: String?){
//        CoroutineScope(Dispatchers.IO).launch {
//            videoRepository?.getNoteInfo(videoId)?.let { response ->
//                Log.d("response ->" ,"response ->$response")
//                if (response.isSuccessful) {
//                    response.body()?.let { body ->
//                        body.data.let {
//                            currentNoteData.postValue(it)
//                        }
//                    }
//                } else Log.e(TAG, "Failed Network")
//            }
//        }
//    }
//
//    fun clear(){
//        currentNoteData.postValue(null)
//    }
//
//
//    fun uploadNote(context: Context,videoId: String?, getPaint : ArrayList<NoteStroke> ) {
//        if (Preferences.token.isEmpty()) {
//            context.apply {
//                alert(message = resources.getString(R.string.content_text_would_you_like_to_login)) {
//                    yesButton {startActivity(intentFor<LoginActivity>().singleTop()) }
//                    noButton { dialog -> dialog.dismiss() }
//                }.show()
//            }
//        } else {
//            CoroutineScope(Dispatchers.IO).launch {
//                val g = Gson()
//                val sJson = g.toJson(NoteJson(Constants.ASPECT_RATIO, getPaint))
//                videoRepository?.uploadNoteInfo(videoId,sJson)?.let { response ->
//                    if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
//                    if (response.isSuccessful) {
//                        withContext(Dispatchers.Main){
//                            context.toast("업로드 완료")
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//
//    fun initGuestNoteData(videoId: String?){
//        CoroutineScope(Dispatchers.IO).launch {
//            videoRepository?.getGuestNoteInfo(videoId)?.let { response ->
//                if (response.isSuccessful) {
//                    response.body()?.let {
//                        currentNoteData.postValue(it)
//                    }
//                } else Log.e(TAG, "Failed Network")
//            }
//        }
//    }

//    private fun initGuestNoteData() {
//        Log.d(TAG, "loadNotes videoId => $videoId")
//        RetrofitClient.getService().getGuestNoteInfo(videoId.toString()).enqueue(object:
//            Callback<NoteCanvasData> {
//            override fun onFailure(call: Call<NoteCanvasData>, t: Throwable) {
//                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
//            }
//
//            override fun onResponse(call: Call<NoteCanvasData>, response: Response<NoteCanvasData>) {
//                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
//                if (response.isSuccessful) {
//                    response.body()?.apply {
//                        Log.d(TAG, "initGuestNoteData : onResponse => $this")
//                        noteData = this
//                        notes?.let {
//                            for (path in it) {
//                                val imageTask =  VideoNoteActivity.URLtoBitmapTask()
//                                    .apply { url = URL("${Constants.FILE_DOMAIN}/$path") }
//                                val bitmap = imageTask.execute().get()
//                                binding.canvasBackground.addImage(bitmap)
//                            }
//                            binding.canvasBackground.invalidate()
//                            binding.canvasBackground.requestLayout()
//                        }
//                        binding.canvasView.setLayoutSize(binding.canvasBackground.getLayoutHeight())
//                        binding.canvasView.invalidate()
//                        binding.canvasView.requestLayout()
//                        binding.canvasView.clear()
//                        binding.canvasView.requestFocus()
//                    }
//                }
//            }
//        })
//    }






}