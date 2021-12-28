@file:Suppress("DEPRECATION")

package com.gongmanse.app.activities

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.os.AsyncTask
import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import android.view.View
import android.view.WindowManager
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.api.SSLHelper
import com.gongmanse.app.databinding.ActivityVideoNoteBinding
import com.gongmanse.app.model.*
import com.gongmanse.app.utils.*
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.upstream.DefaultAllocator
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util
import com.google.gson.Gson
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.net.URL
import javax.net.ssl.HttpsURLConnection

class VideoNoteActivity : AppCompatActivity(), View.OnClickListener {

    private lateinit var binding: ActivityVideoNoteBinding
    private lateinit var noteData : NoteCanvasData
    private lateinit var sJson : NoteJson
    private var mPlayerPosition : Long = 0
    private var items: ArrayList<VideoData> = arrayListOf()
    private var videoId : String? = null
    private var seriesId : String? = null
    private var position = -1
    private var videoURL:String = ""
    private var playBool = true
    private var type : Int = 0
    private var type2: Int = 0
    private var grade :String? = null
    private var subjectId : Int? = null
    private var keyword : String? = null
    private var sortId : Int = 0
    private var videoInfo : VideoData? = null
    private var totalItemNum : Int = 0
    private var mPlayer: SimpleExoPlayer? = null
    private lateinit var mVideoNoteViewModel: VideoNoteViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        hasExpireCheck()
    }

    override fun onClick(v: View?) {
        when(v?.id){
            android.R.id.home -> onBackPressed()
            R.id.btn_close -> {
                if(intent.hasExtra(Constants.EXTRA_KEY_VIDEO_ID)){
                    backToVideo()
                }else{
                    backNoteList()
                }
            }
            R.id.ic_close -> playerClose()
            R.id.ic_play  -> resume()
            R.id.ic_pause -> pause()
        }
    }

    private fun wifiAlert(){
        alert(
            title = null,
            message = " WIFI 를 연결하거나, 설정에서 모바일 데이터 사용을 허용해주세요"
        ) {
            positiveButton("설정") {
                it.dismiss()
                startActivity(intentFor<SettingActivity>().singleTop())
            }
            negativeButton("닫기") {
                it.dismiss()
            }
        }.show()
    }

    override fun onBackPressed() {
        if(intent.hasExtra(Constants.EXTRA_KEY_VIDEO_ID)){
            backToVideo()
        }else{
            backNoteList()
        }
    }

    fun videoClick(item: MenuItem){
        if(intent.hasExtra(Constants.EXTRA_KEY_VIDEO_ID)){
            backToVideo()
        }else{
            val wifiState = IsWIFIConnected().check(this)
            if (!Preferences.mobileData && !wifiState) {
                wifiAlert()
            }else{
                if (items[position].iActive == "1") {
                    newVideo()
                } else {
                    Toast.makeText(this, "해당 강의는 취소되었습니다.", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    private fun hasExpireCheck() {
        if (Commons.hasExpire().not()) {
            toast("이용권을 구매해주세요.")
            finish()
        } else {
            binding = DataBindingUtil.setContentView(this, R.layout.activity_video_note)
            binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_NOTE_SHOW
            initData()
            initView()
            setLiveData()
        }
    }


    private fun setLiveData(){
//        val mVideoNoteViewModelFactory = VideoNoteViewModelFactory(VideoRepository())
//        binding.apply {
//            this@VideoNoteActivity.let { context ->
//                mVideoNoteViewModel = ViewModelProvider(context, mVideoNoteViewModelFactory).get(VideoNoteViewModel::class.java)
//                lifecycleOwner = context
//            }
//        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun initData(){
        when {
            // 홈쪽에서 넘어왔을때
            intent.hasExtra(Constants.EXTRA_KEY_ITEMS) -> {
                items = intent.getSerializableExtra(Constants.EXTRA_KEY_ITEMS) as ArrayList<VideoData>
                position = intent.getIntExtra(Constants.EXTRA_KEY_NOW_POSITION , 0)
                videoId = items[position].videoId
                seriesId = items[position].seriesId
                type = intent.getIntExtra(Constants.EXTRA_KEY_TYPE,-1)
                type2 = intent.getIntExtra(Constants.EXTRA_KEY_TYPE2,-1)
                totalItemNum = intent.getIntExtra(Constants.EXTRA_KEY_TOTAL_NUM,0)
                Log.v(TAG, "EXTRA_KEY_ITEMS : type=$type, type2=$type2")
            }
            // 검색 결과: 노트보기에서 넘어 왔을때
            intent.hasExtra(Constants.EXTRA_KEY_SEARCH_NOTE) -> {
                items = intent.getSerializableExtra(Constants.EXTRA_KEY_SEARCH_NOTE) as ArrayList<VideoData>
                position = intent.getIntExtra(Constants.EXTRA_KEY_POSITION , 0)
                videoId = items[position].videoId
                seriesId = items[position].seriesId
                grade =intent.getStringExtra(Constants.EXTRA_KEY_GRADE)
                subjectId = intent.getIntExtra(Constants.EXTRA_KEY_SUBJECT_ID ,0)
                keyword = intent.getStringExtra(Constants.EXTRA_KEY_KEYWORD)
                sortId = intent.getIntExtra(Constants.EXTRA_KEY_SORT_ID,0)
                type2 = intent.getIntExtra(Constants.EXTRA_KEY_TYPE2,-1)
                totalItemNum = intent.getIntExtra(Constants.EXTRA_KEY_TOTAL_NUM,0)
            }
            // 비디오 재생중 넘어 왔을때
            intent.hasExtra(Constants.EXTRA_KEY_VIDEO_ID) -> {
                videoId = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_ID)
                seriesId = intent.getStringExtra(Constants.EXTRA_KEY_SERIES_ID)
                mPlayerPosition = intent.getLongExtra(Constants.EXTRA_KEY_VIDEO_POSITION,0)
                videoURL = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_URL).toString()
                noteData = intent.getSerializableExtra(Constants.EXTRA_KEY_NOTE_DATA) as NoteCanvasData
                sJson = intent.getSerializableExtra(Constants.EXTRA_KEY_NOTE_JSON) as NoteJson
                intent.getSerializableExtra(Constants.EXTRA_KEY_DATA)?.let {
                    videoInfo = intent.getSerializableExtra(Constants.EXTRA_KEY_DATA) as VideoData
                }
                totalItemNum = intent.getIntExtra(Constants.EXTRA_KEY_TOTAL_NUM,0)

                Log.d(TAG,"strokes => $sJson")
                Log.d(TAG,"NoteCanvasData => $noteData")
                if (Preferences.token.isEmpty()) loadVideoInfoBest(videoId) else loadVideoInfo(videoId)
                binding.tvBack.visibility = View.GONE
                binding.tvNext.visibility = View.GONE
                binding.layoutPlayer.visibility = View.VISIBLE
                binding.setVariable(BR.data, videoInfo)
            }
            // 나의 활동
            intent.hasExtra(Constants.EXTRA_KEY_ACTIVE_NOTE) -> {
                items = intent.getSerializableExtra(Constants.EXTRA_KEY_ACTIVE_NOTE) as ArrayList<VideoData>
                position = intent.getIntExtra(Constants.EXTRA_KEY_POSITION , 0)
                videoId = items[position].videoId
                seriesId = items[position].seriesId
                sortId = intent.getIntExtra(Constants.EXTRA_KEY_SORT_ID,0)
                type2 = intent.getIntExtra(Constants.EXTRA_KEY_TYPE2,-1)
                totalItemNum = intent.getIntExtra(Constants.EXTRA_KEY_TOTAL_NUM,0)
            }
        }

//        if(intent.hasExtra(("id"))){//??
//            videoId = intent.getStringExtra("id")
//            totalItemNum = intent.getIntExtra(Constants.EXTRA_KEY_TOTAL_NUM,0)
//            position = intent.getIntExtra("position" , -1)
//            Log.d(TAG, "position=> $position")
//        }

        Log.v(TAG, "videoId => $videoId")
        Log.v(TAG, "seriesId => $seriesId")

        checkSize()
        buttonClick()

    }

    private fun initView() {
        binding.canvasView.setLayerType(View.LAYER_TYPE_HARDWARE, null)
        initListener()
        initNoteData()
    }

    private fun newVideo(){
        val intent = Intent(this, VideoActivity::class.java)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, videoId.toString())
        intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, seriesId ?: "0")
        intent.putExtra(Constants.EXTRA_KEY_TYPE, type)
        startActivity(intent)
        finish()
    }

    private fun backToVideo(){
        val mPlayerPosition = mPlayer?.currentPosition
        val strokes = binding.canvasView.getPaints()
        sJson  = NoteJson(Constants.ASPECT_RATIO, strokes)
        Log.d("넘기기전 제이슨","sJson => $sJson")
        val intent = Intent()
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_POSITION,mPlayerPosition)
        intent.putExtra(Constants.EXTRA_KEY_NOTE_JSON, sJson)
        setResult(RESULT_OK,intent)
        releasePlayer()
        finish()
    }

    private fun returnFromVideo(){
        noteData.apply {
            Log.d(TAG, "NoteCanvasData back => $this")
            notes?.let {
                binding.canvasBackground.clear()
                for (path in it) {
                    val imageTask =  URLtoBitmapTask().apply { url = URL("${Constants.FILE_DOMAIN}/$path") }
                    val bitmap = imageTask.execute().get()
                    binding.canvasBackground.addImage(bitmap)
                }
            }
            binding.canvasView.setLayoutSize(binding.canvasBackground.getLayoutHeight())
            binding.canvasView.invalidate()
            binding.canvasView.requestLayout()
            sJson.let {
                binding.canvasView.addPaint(it)
            }
            binding.canvasView.requestFocus()
        }
        val uri = Uri.parse(videoURL)
        initPlayer(uri)
    }

    private fun playVideo(){
            binding.icPlay.visibility = View.GONE
            binding.icPause.visibility = View.VISIBLE
            playBool = true
    }

    private fun playerClose() {
        binding.layoutPlayer.visibility = View.GONE
        pause()
    }

    private fun resume(){
        mPlayer?.playWhenReady = true
        binding.icPlay.visibility = View.GONE
        binding.icPause.visibility = View.VISIBLE
        playBool = true
    }

    private fun pause(){
        mPlayer?.playWhenReady = false
        binding.icPlay.visibility = View.VISIBLE
        binding.icPause.visibility = View.GONE
        playBool = false
    }

    private fun releasePlayer() {
        if (mPlayer != null) {
            with(mPlayer) {
                this?.playWhenReady = false
                this?.release()
            }
            mPlayer = null
        }
        if (::binding.isInitialized) {
            binding.videoView2.player = null
        }
    }

    private fun checkSize(){
        Log.e(TAG,"totalItemNum : $totalItemNum")
        if(position >= totalItemNum){
            when(type2){
                Constants.NOTE_TYPE_KEM     -> {loadVideoNote(type, items.size)}
                Constants.NOTE_TYPE_SCIENCE -> {loadVideoNote(type, items.size)}
                Constants.NOTE_TYPE_SOCIETY -> {loadVideoNote(type, items.size)}
                Constants.NOTE_TYPE_ETC     -> {loadVideoNote(type, items.size)}
                Constants.NOTE_TYPE_SEARCH  -> {loadVideoNote(items.size)}
                Constants.NOTE_TYPE_ACTIVE  -> {loadActiveVideoNote(items.size.toString())}
            }
        }
    }

    private fun buttonClick(){
        try{
            binding.tvNext.setOnClickListener {
                val size = items.size
                Log.d(TAG,"curIdx : $position, maxIdx : ${size-1}")
                if(position != -1) {
                    if(items.size != totalItemNum) {
                        if(position >= size - 4 && size >= 20) {// items.size < totalItemNum...
                            Log.d("진입" ,"$type2")
                            when(type2){
                                Constants.NOTE_TYPE_KEM     -> {loadVideoNote(type2, items.size)}
                                Constants.NOTE_TYPE_SCIENCE -> {loadVideoNote(type2, items.size)}
                                Constants.NOTE_TYPE_SOCIETY -> {loadVideoNote(type2, items.size)}
                                Constants.NOTE_TYPE_ETC     -> {loadVideoNote(type2, items.size)}
                                Constants.NOTE_TYPE_SEARCH  -> {loadVideoNote(items.size)}
                                Constants.NOTE_TYPE_ACTIVE  -> {loadActiveVideoNote(items.size.toString())}
                            }
                        }
                    } else if(position == size - 1 ){
                        toast("다음 목록이 없습니다.")
                        position -= 1
                    }
                    position += 1
                    videoId = items[position].videoId
                    seriesId = items[position].seriesId
                }
                binding.progressBar.visibility = View.VISIBLE
                initNoteData()
            }
            binding.tvBack.setOnClickListener {
                if(position > 0){
                    position -= 1
                    videoId = items[position].videoId
                    seriesId = items[position].seriesId
                }else if(position == 0){
                    toast("이전 목록이 없습니다.")
                }
                binding.progressBar.visibility = View.VISIBLE
                initNoteData()
            }
        }catch (e : Exception){
            toast("목록이 없습니다. 관리자에게 문의 하여 주세요 ")
            Log.e(TAG,"$e")
        }

    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initListener() {
        binding.sliding.setOnDrawerOpenListener {
            binding.canvasView.changeDrawing(true)
            binding.handleClose.visibility = View.INVISIBLE
            binding.handleOpen.visibility = View.VISIBLE
            binding.btnCanvasShow.text = resources.getString(R.string.content_button_canvas_save)
            binding.btnCanvasShow.visibility = View.VISIBLE
            binding.tvBack.visibility = View.GONE
            binding.tvNext.visibility = View.GONE
        }
        binding.sliding.setOnDrawerCloseListener {
            binding.canvasView.changeDrawing(false)
            binding.handleClose.visibility = View.VISIBLE
            binding.handleOpen.visibility = View.INVISIBLE
            binding.btnCanvasShow.visibility = View.GONE
            if(this::sJson.isInitialized){
                binding.tvBack.visibility = View.GONE
                binding.tvNext.visibility = View.GONE
            }else{
                if (intent.hasExtra(Constants.EXTRA_KEY_SEARCH)) {
                    binding.tvNext.visibility = View.GONE
                    binding.tvBack.visibility = View.GONE
                }else{
                    binding.tvBack.visibility = View.VISIBLE
                    binding.tvNext.visibility = View.VISIBLE
                }
            }

        }
        binding.content.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                R.id.rb_1 -> binding.canvasView.changeColor(GraphicView.MODE_PEN_RED)
                R.id.rb_2 -> binding.canvasView.changeColor(GraphicView.MODE_PEN_GREEN)
                R.id.rb_3 -> binding.canvasView.changeColor(GraphicView.MODE_PEN_BLUE)
                R.id.rb_4 -> binding.canvasView.changeEraser()
            }
        }
        binding.btnCanvasShow.setOnClickListener {
            if (Preferences.token.isEmpty()) toast(getString(R.string.content_text_toast_login)) else uploadNote()
        }

    }

    private fun initNoteData() {
        try {
            binding.tvNext.isEnabled =false
            binding.tvBack.isEnabled =false
            if(!intent.hasExtra(Constants.EXTRA_KEY_VIDEO_ID)){
                RetrofitClient.getService().getNoteInfo(Preferences.token, videoId.toString()).enqueue(object: Callback<NoteCanvas> {
                    override fun onFailure(call: Call<NoteCanvas>, t: Throwable) {
                        binding.progressBar.visibility = View.GONE
                        Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                    }
                    override fun onResponse(call: Call<NoteCanvas>, response: Response<NoteCanvas>) {
                        if (!response.isSuccessful)
                            binding.progressBar.visibility = View.GONE
                        if (response.isSuccessful) {
                            response.body()?.apply {
                                Log.d(TAG, "onResponse => ${this.data}")
                                data?.apply {
                                    binding.canvasBackground.clear()
                                    notes?.let {
                                        for (path in it) {
                                            val imageTask =  URLtoBitmapTask().apply { url = URL("${Constants.FILE_DOMAIN}/$path") }
                                            val bitmap = imageTask.execute().get()
                                            binding.canvasBackground.addImage(bitmap)
                                        }
                                        binding.canvasBackground.invalidate()
                                        binding.canvasBackground.requestLayout()
                                    }
                                    binding.canvasView.setLayoutSize(binding.canvasBackground.getLayoutHeight())
                                    binding.canvasView.invalidate()
                                    binding.canvasView.requestLayout()
                                    binding.canvasView.clear()
                                    json?.let {
                                        binding.canvasView.addPaint(it)
                                    }
                                    binding.canvasView.requestFocus()
                                    binding.progressBar.visibility = View.GONE
                                    binding.tvNext.isEnabled =true
                                    binding.tvBack.isEnabled =true
                                }
                            }
                        }
                    }
                })
            }else{
                Log.d(TAG, "strokes => returnFromVideo()////")
                returnFromVideo()
                binding.progressBar.visibility = View.GONE
            }
        }catch (e: Exception){
            Log.e(TAG,"메모리부족")
        }
    }

    private fun uploadNote() {
        val g = Gson()
        val strokes = binding.canvasView.getPaints()
        val sJson = g.toJson(NoteJson(Constants.ASPECT_RATIO, strokes))
        Log.d(TAG, "sJson => $sJson")
        RetrofitClient.getService().uploadNoteInfo(Preferences.token, videoId.toString(), sJson).enqueue(object: Callback<Void> {
            override fun onFailure(call: Call<Void>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Void>, response: Response<Void>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    toast("업로드 완료")
                }
            }
        })

    }

    // 비로그인
    private fun loadVideoInfoBest(id: String?) {
        Log.d(TAG,"loadVideoInfo id:$id")
        if (id != null) {
            RetrofitClient.getService().getVideoInfoBest(id).enqueue( object : Callback<Video> {
                override fun onFailure(call: Call<Video>, t: Throwable) {
                    Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(call: Call<Video>, response: Response<Video>) {
                    if (response.isSuccessful) {
                        response.body()?.apply {
                            binding.data = this.data
                        }
                    } else Log.d(TAG, "Load Video Info of Best, Failed API code : ${response.code()} - message : ${response.message()}")
                }
            })
        }
    }

    // 로그인
    private fun loadVideoInfo(id : String?){
        Log.d(TAG, "loadVideoInfo id:$id\n Token:${Preferences.token}")
        RetrofitClient.getService()
            .getVideoInfo(Preferences.token, id.toString())
            .enqueue(object: Callback<Video> {
                override fun onFailure(call: Call<Video>, t: Throwable) {
                    Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                }
                override fun onResponse(call: Call<Video>, response: Response<Video>) {
                    if (response.isSuccessful) {
                        response.body()?.apply {
                           this.data.let {
                               Log.e(TAG, "VideoData => $this")
                               binding.data = it
                           }
                        }
                    } else Log.d(TAG, "Load Video Info Failed API code : ${response.code()} - message : ${response.message()}")
                }
            })
    }

    class URLtoBitmapTask : AsyncTask<Void, Void, Bitmap>() {
        lateinit var url: URL
        override fun doInBackground(vararg params: Void?): Bitmap {
            HttpsURLConnection.setDefaultSSLSocketFactory(SSLHelper.getInstance().sslContext.socketFactory)
            return try {
                BitmapFactory.decodeStream(url.openStream())
            } catch (e: Exception) {
                e.printStackTrace()
                Bitmap.createBitmap(10,10,Bitmap.Config.ARGB_8888)
            }
        }

        override fun onPostExecute(result: Bitmap?) {
            super.onPostExecute(result)
        }
    }

    private fun loadActiveVideoNote(offset: String) {// 나의 활동
        RetrofitClient.getService().getNoteList(Preferences.token, sortId, offset, "20").enqueue(object: Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<VideoList>, response: Response<VideoList>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {
                        this.data.let {
                            items.addAll(it as List<VideoData>)
                            Log.e(TAG, "isSuccessful : $it")
                        }
                    }
                }
            }
        })
    }
    private fun loadVideoNote(type : Int,offset: Int) {// 홈
        val categoryId : Int = when(type){
            Constants.NOTE_TYPE_KEM -> Constants.GRADE_SORT_ID_KEM
            Constants.NOTE_TYPE_SCIENCE -> Constants.GRADE_SORT_ID_SCIENCE
            Constants.NOTE_TYPE_SOCIETY -> Constants.GRADE_SORT_ID_SOCIETY
            Constants.NOTE_TYPE_ETC -> Constants.GRADE_SORT_ID_ETC
            else -> 34
        }

        RetrofitClient.getService().getNoteList(categoryId, offset).enqueue( object :
            Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }
            override fun onResponse(
                call: Call<VideoList>,
                response: Response<VideoList>
            ) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {

                    response.body()?.apply {
                        this.data.let{
                            items.addAll(it as List<VideoData>)
                        }
                    }
                }
            }
        })
    }
    private fun loadVideoNote(offset: Int){// 검색
        if(subjectId == 0){
            subjectId = null
        }
        Log.d("진입후","subjectId : $subjectId - grade : $grade - keyword : $keyword - sortId : $sortId - Constants.LIMIT_DEFAULT : ${Constants.LIMIT_DEFAULT}")
        RetrofitClient.getService().getSearchNoteList(subjectId, grade, keyword, sortId, offset.toString(), Constants.LIMIT_DEFAULT ).enqueue( object : Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(
                call: Call<VideoList>,
                response: Response<VideoList>
            ) {
                if (response.isSuccessful) {

                    response.body()?.apply {
                        this.data.let {
                            items.addAll(it as List<VideoData>)
                            Log.e(TAG, "isSuccessful : $it")
                        }
                    }
                } else Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
            }
        })
    }

    private fun backNoteList(){
        if(items.size == 0){
            finish()
        }else{
            val intent = Intent()
            intent.putExtra(Constants.EXTRA_KEY_ITEMS,items)
            intent.putExtra(Constants.EXTRA_KEY_POSITION, position)
            when(type){
                Constants.NOTE_TYPE_KEM         -> intent.putExtra(Constants.EXTRA_KEY_TYPE , Constants.NOTE_TYPE_KEM)
                Constants.NOTE_TYPE_SCIENCE     -> intent.putExtra(Constants.EXTRA_KEY_TYPE , Constants.NOTE_TYPE_SCIENCE)
                Constants.NOTE_TYPE_SOCIETY     -> intent.putExtra(Constants.EXTRA_KEY_TYPE , Constants.NOTE_TYPE_SOCIETY)
                Constants.NOTE_TYPE_ETC         -> intent.putExtra(Constants.EXTRA_KEY_TYPE , Constants.NOTE_TYPE_ETC)
                Constants.NOTE_TYPE_SEARCH      -> intent.putExtra(Constants.EXTRA_KEY_TYPE , Constants.NOTE_TYPE_SEARCH)
            }
            setResult(RESPONSE_CODE,intent)
            finish()
        }
    }

    private fun initPlayer(uri: Uri) {
        val loadControl = DefaultLoadControl.Builder()
            .setAllocator(DefaultAllocator(TRIM_ON_RESET, INDIVIDUAL_ALLOCATION_SIZE)) // DefaultAllocator 로더 가 사용하는을 설정합니다 .
            .setBufferDurationsMs(
                MIN_BUFFER_DURATION,
                MAX_BUFFER_DURATION,
                PLAYBACK_START_BUFFER_DURATION,
                PLAYBACK_RESUME_BUFFER_DURATION
            ) // 버퍼 기간 매개 변수를 설정합니다.
            .setTargetBufferBytes(TARGET_BUFFER_BYTES) // 대상 버퍼 크기를 바이트 단위로 설정합니다. 로 설정 C.LENGTH_UNSET 하면 선택한 트랙을 기준으로 대상 버퍼 크기가 계산됩니다.
            .setPrioritizeTimeOverSizeThresholds(PRIORITIZE_TIME_OVER_SIZE_THRESHOLDS) // 로드 제어가 버퍼 크기 제약보다 버퍼 시간 제약의 우선 ​​순위를 지정하는지 여부를 설정합니다.
            .createDefaultLoadControl()
        // ExoPlayer 트랙 선택기
        val trackSelector = DefaultTrackSelector()
        // ExoPlayer 확장 렌더러
        val renderersFactory = DefaultRenderersFactory(this)
        mPlayer = ExoPlayerFactory.newSimpleInstance(
            this,
            renderersFactory,
            trackSelector,
            loadControl
        ).apply {
            val source = ProgressiveMediaSource.Factory(getDefaultDataSourceFactory()).createMediaSource(uri)
            prepare(source)
            playWhenReady = mPlayerPosition != -1L
            seekTo(mPlayerPosition)

            addListener(object: Player.EventListener {
                override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                    if (playbackState == Player.STATE_READY) {
                        if (playWhenReady)
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        else
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                }
            })
        }
        binding.videoView2.apply {
            this.videoSurfaceView?.setOnClickListener { backToVideo() }
            this.useController = false // 컨트롤러 사용 안함
            this.subtitleView?.visibility = View.GONE // 내장 subtitleView 숨김
            this.setShutterBackgroundColor(Color.TRANSPARENT) // exo_shutter 투명처리 : 동영상을 숨겨야 할 때 표시되는 보기
            this.player = mPlayer
        }
        if (mPlayerPosition == -1L) {
            pause()
            binding.icPlay.isClickable = false
        } else {
            playVideo()
        }
    }

    private fun getDefaultDataSourceFactory(): DefaultDataSourceFactory {
        return DefaultDataSourceFactory(this, Util.getUserAgent(this, resources.getString(R.string.app_name))
        )
    }

    companion object {
        private val TAG = VideoNoteActivity::class.java.simpleName
        private const val TRIM_ON_RESET = true // 할당 자 재설정시 메모리 해제 여부. 할당자가 여러 플레이어 인스턴스에서 재사용되지 않는 한 참이어야 합니다.
        private const val INDIVIDUAL_ALLOCATION_SIZE = 16 // 각 Allocation 의 길이
        private const val TARGET_BUFFER_BYTES = -1 // 대상 버퍼 크기 : 바이트 단위
        private const val PRIORITIZE_TIME_OVER_SIZE_THRESHOLDS = true // 부하 제어가 버퍼 크기 제약보다 버퍼 시간 제약을 우선시하는지 여부
        private const val MIN_BUFFER_DURATION = 2000 // 플레이어가 항상 버퍼링을 시도하는 미디어의 최소 기간 : 2초
        private const val MAX_BUFFER_DURATION = 5000 // 플레이어가 버퍼링을 시도하는 미디어의 최대 기간 : 5초
        private const val PLAYBACK_START_BUFFER_DURATION  = 1500 // 탐색과 같은 사용자 작업 후 재생을 시작하거나 다시 시작하기 위해 버퍼링해야하는 미디어의 지속 시간 : 1.5초
        private const val PLAYBACK_RESUME_BUFFER_DURATION = 2000 // 리 버퍼 후 재생을 재개하기 위해 버퍼링해야하는 미디어의 기본 기간 : 2초
        const val RESPONSE_CODE = 9001
    }

}