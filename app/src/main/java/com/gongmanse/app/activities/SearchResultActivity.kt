package com.gongmanse.app.activities

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.R
import com.gongmanse.app.adapter.search.SearchNoteRVAdapter
import com.gongmanse.app.adapter.search.SearchResultTabPagerAdapter
import com.gongmanse.app.adapter.search.SearchVideoLoadingRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivitySearchResultBinding
import com.gongmanse.app.fragments.search.SearchCounselFragment
import com.gongmanse.app.fragments.search.SearchNoteFragment
import com.gongmanse.app.fragments.search.SearchVideoFragment
import com.gongmanse.app.model.ActionType
import com.gongmanse.app.model.NoteLiveDataModel
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.upstream.DefaultAllocator
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util
import com.google.android.material.tabs.TabLayout
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class SearchResultActivity : AppCompatActivity(), View.OnClickListener {
    private lateinit var binding: ActivitySearchResultBinding
    private lateinit var mAdapter: SearchResultTabPagerAdapter
    private lateinit var bottomVideoInfo : HashMap<String,Any?>
    private var grade: String? = null
    private var subjectId: Int? = null
    private var keyword: String? = null
    private var videoId: String? = null
    private var playBool = false
    private var videoURL: String? = null
    private var playerPosition : Long? = 0
    private var from: Boolean = true
    private var videoTitle = ""
    private var teacherName =""
    private var bottomSeriesId : String? = null
    private var bottomSubjectId : Int? = null
    private var bottomSorting : Int = Constants.CONTENT_RESPONSE_VALUE_LATEST
    private var bottomGrade : String? = null
    private var bottomKeyword : String? = null
    private var bottomQueryType : Int? = null
    private var bottomNowPosition : Int? = null
    private var mPlayer: SimpleExoPlayer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_search_result)
        initView()
    }

    override fun onResume() {
        super.onResume()
        if (playerPosition == -1L) {
            pause()
        } else {
            resume()
        }
    }

    override fun onStop() {
        super.onStop()
        pause()
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            android.R.id.home -> onBackPressed()
            R.id.btn_close    -> onBackPressed()
            R.id.ic_close     -> playerClose()
            R.id.ic_play      -> resume()
            R.id.ic_pause     -> pause()
        }
    }

    override fun onBackPressed() {
        backToVideo()
    }

    @Suppress("UNCHECKED_CAST")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.d(TAG, "onActivityResult(), requestCode : $requestCode")
        if (resultCode == Activity.RESULT_OK) {
            when(requestCode) {
                0 -> {
                    Log.d(TAG," resultCode = > RESULT_OK")
                    if (data?.hasExtra(Constants.EXTRA_KEY_VIDEO_ID)!!) {
                        videoId = data.getStringExtra(Constants.EXTRA_KEY_VIDEO_ID)
                        videoURL = data.getStringExtra(Constants.EXTRA_KEY_VIDEO_URL).toString()
                        playerPosition = data.getLongExtra(Constants.EXTRA_KEY_VIDEO_POSITION, 0)
                        binding.layoutPlayer.visibility = View.VISIBLE
                        Log.i(TAG, "Video Id =>$videoId \nVideoUrl => $videoURL \nVideoPlayPosition => $playerPosition \n keyword => $keyword \n")
                    }
                }
                SearchVideoLoadingRVAdapter.REQUEST_CODE -> {
                    Log.v(TAG,"requestCode => $requestCode")
                    if (Preferences.token.isNotEmpty()) Constants.getProfile() else Log.v(TAG,"Preferences.token is null")
                }
                SearchNoteRVAdapter.REQUEST_CODE_LOGIN -> {
                    Log.v(TAG,"requestCode => $requestCode")
                    if (Preferences.token.isNotEmpty()) Constants.getProfile() else Log.v(TAG,"Preferences.token is null")
                }
            }
        }
        if(requestCode == SearchNoteRVAdapter.REQUEST_CODE){
            when(resultCode){
                RESULT_OK -> {
                    Log.v(TAG,"ResultOk")
                    resume()
                }
                VideoNoteActivity.RESPONSE_CODE -> {
                    Log.d(TAG,"getData => $data")
                    if(data!=null){
                        val items = data.getSerializableExtra(Constants.EXTRA_KEY_ITEMS) as ArrayList<VideoData>
                        val position = data.getIntExtra(Constants.EXTRA_KEY_POSITION,0)
                        val type = data.getIntExtra(Constants.EXTRA_KEY_TYPE,-1)
                        listData.updateValue(ActionType.CLEAR,items,position,type)
                        listData.updateValue(ActionType.SET,items,position,type)
                        Log.d(TAG,"getData2 => $items")
                        Log.d(TAG,"liveData => ${listData.currentValue.value}")
                    }
                }
            }
        }

    }

    private fun initView() {
        hasExtra()
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_SEARCH
        binding.layoutToolbar.btnClose.setOnClickListener { onBackPressed() }
        setAdapter()
        clickEvent()
        setLiveData()
    }

    private fun setLiveData(){
        listData = ViewModelProvider(this).get(NoteLiveDataModel::class.java)
    }

    private fun hasExtra() {

        if (intent.hasExtra(Constants.EXTRA_KEY_GRADE))          intent.getStringExtra(Constants.EXTRA_KEY_GRADE)?.let { it -> grade = it }
        if (intent.hasExtra(Constants.EXTRA_KEY_SUBJECT_ID))     intent.getIntExtra(Constants.EXTRA_KEY_SUBJECT_ID, 0).let { subject_id -> subjectId = if (subject_id == 38 || subject_id ==0 ) null else subject_id }
        if (intent.hasExtra(Constants.EXTRA_KEY_KEYWORD))        intent.getStringExtra(Constants.EXTRA_KEY_KEYWORD)?.let { it ->
            keyword = it
            binding.inputSearch.setText(keyword)
        }
        Log.i(TAG,"Grade:$grade, subjectId:$subjectId, keyword:$keyword")
        // VideoActivity
        if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_URL)) {
            from = false
            videoURL = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_URL).toString()
            playerPosition = intent.getLongExtra(Constants.EXTRA_KEY_VIDEO_POSITION, 0)
            videoTitle = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_TITLE).toString()
            teacherName = intent.getStringExtra(Constants.EXTRA_KEY_TEACHER_NAME).toString()

            Log.v(TAG, "playerPosition => $playerPosition")
            Log.v(TAG, "videoTitle => $videoTitle")
            Log.v(TAG, "teacherName => $teacherName")

            videoId  = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_ID)
            bottomSeriesId = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID)
            bottomSubjectId = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID, 0)
            bottomGrade = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_GRADE)
            bottomSorting = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, Constants.CONTENT_RESPONSE_VALUE_LATEST)
            bottomKeyword = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD)
            bottomQueryType = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE,0)
            bottomNowPosition = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION, 0)

            Log.v(TAG, "videoId => $videoId")
            Log.v(TAG, "bottomSeriesId => $bottomSeriesId")
            Log.v(TAG, "bottomSubjectId => $bottomSubjectId")
            Log.v(TAG, "bottomGrade => ${bottomGrade ?: 123}")
            Log.v(TAG, "bottomSorting => $bottomSorting")
            Log.v(TAG, "bottomKeyword => $bottomKeyword")
            Log.v(TAG, "bottomQueryType => $bottomQueryType")
            Log.v(TAG, "bottomNowPosition => $bottomNowPosition")

            Log.i(TAG, "videoTitle => $videoTitle\n teacherName => $teacherName\n VideoPlayPosition => $playerPosition\n from => $from ")
            bottomVideoInfo = hashMapOf(
                Constants.EXTRA_KEY_VIDEO_ID to videoId
                ,   Constants.EXTRA_KEY_VIDEO_POSITION to playerPosition!!
                ,   Constants.EXTRA_KEY_VIDEO_URL to videoURL!!
                ,   Constants.EXTRA_KEY_VIDEO_TITLE to videoTitle
                ,   Constants.EXTRA_KEY_TEACHER_NAME to teacherName
                ,   Constants.EXTRA_KEY_BOTTOM_SERIES_ID to bottomSeriesId
                ,   Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID to bottomSubjectId
                ,   Constants.EXTRA_KEY_BOTTOM_GRADE to bottomGrade
                ,   Constants.EXTRA_KEY_BOTTOM_SORTING to bottomSorting
                ,   Constants.EXTRA_KEY_BOTTOM_KEYWORD to bottomKeyword
                ,   Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE to bottomQueryType
                ,   Constants.EXTRA_KEY_BOTTOM_NOW_POSITION to bottomNowPosition
            )

            binding.apply {
                tvBottomTitle.text = videoTitle
                tvBottomName.text  = teacherName

                layoutPlayer.visibility = View.VISIBLE
                videoURL?.let { initPlayer(Uri.parse(it)) }
            }

        }

    }

    private fun initPlayer(uri: Uri) {
        val loadControl = DefaultLoadControl.Builder()
            .setAllocator(
                DefaultAllocator(
                TRIM_ON_RESET,
                INDIVIDUAL_ALLOCATION_SIZE
            )
            ) // DefaultAllocator 로더 가 사용하는을 설정합니다 .
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
            playerPosition?.let {
                playWhenReady = it != -1L
                seekTo(it)
            }

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
        binding.videoView.apply {
            useController = false // 컨트롤러 사용 안함
            subtitleView?.visibility = View.GONE // 내장 subtitleView 숨김
            setShutterBackgroundColor(Color.TRANSPARENT) // exo_shutter 투명처리 : 동영상을 숨겨야 할 때 표시되는 보기
            player = mPlayer // player 연결

        }
        playerPosition?.let {
            if (it == -1L) {
                pause()
                binding.icPlay.isClickable = false
            } else {
                playVideo()
            }
        }
    }

    private fun getDefaultDataSourceFactory(): DefaultDataSourceFactory {
        return DefaultDataSourceFactory(this, Util.getUserAgent(this, resources.getString(R.string.app_name))
        )
    }

    private fun playVideo() {
        Log.e(TAG,"playVideo()")
        binding.icPlay.visibility = View.GONE
        binding.icPause.visibility = View.VISIBLE
        playBool = true
    }

    private fun playerClose() {
        binding.layoutPlayer.visibility = View.GONE
        pause()
    }

    private fun resume() {
        mPlayer?.playWhenReady = true
        binding.icPlay.visibility  = View.GONE
        binding.icPause.visibility = View.VISIBLE
        playBool = true
    }

    private fun pause() {
        mPlayer?.playWhenReady = false
        binding.icPlay.visibility  = View.VISIBLE
        binding.icPause.visibility = View.GONE
        playBool = false
    }

    // 플레이어 초기화
    private fun releasePlayer() {
        if (mPlayer != null) {
            with(mPlayer) {
                this?.playWhenReady = false
                this?.release()
            }
            mPlayer = null
        }
        if (::binding.isInitialized) {
            binding.videoView.player = null
        }
    }

    private fun backToVideo(){
        val playerPosition = mPlayer?.currentPosition
        val intent = Intent()
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_URL, videoURL)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_POSITION, playerPosition)
        setResult(Constants.SEARCH_RESULT_CODE, intent)
        releasePlayer()
        finish()
    }

    fun backToVideoInAdapter() {
        releasePlayer()
    }

    fun goToVideoInAdapter() {
        pause()
    }

    private fun setAdapter() {
        if (subjectId == 0 && subjectId == 38) subjectId = null
        mAdapter = SearchResultTabPagerAdapter(supportFragmentManager, grade, subjectId, keyword, from)
        binding.viewPager.apply {
            adapter = mAdapter
            offscreenPageLimit = mAdapter.count
            binding.tabLayout.setupWithViewPager(this)
        }
    }

    fun returnVideoInfo() : HashMap<String,Any?>{
        return if(this::bottomVideoInfo.isInitialized) {
            bottomVideoInfo
        }else{
            hashMapOf(Constants.EXTRA_KEY_VIDEO_ID to null)
        }
    }

    private fun clickEvent() {
        binding.apply {
            // TAB
            tabLayout.addOnTabSelectedListener( object : TabLayout.OnTabSelectedListener {
                override fun onTabReselected(tab: TabLayout.Tab?) {
                    tab?.position.let {
                        Log.d(TAG, "it => $it")
                        when(it) {
                            0 -> (mAdapter.getItem(it) as SearchVideoFragment).scrollToTop()
                            1 -> (mAdapter.getItem(it) as SearchCounselFragment).scrollToTop()
                            2 -> (mAdapter.getItem(it) as SearchNoteFragment).scrollToTop()
                        }
                    }
                }
                override fun onTabUnselected(tab: TabLayout.Tab?) {}

                override fun onTabSelected(tab: TabLayout.Tab?) {}
            })

            // 검색
            inputSearch.setOnEditorActionListener(fun(_, actionId: Int, _): Boolean {
                Log.d(TAG,"Click Event Search Bar!!")
                when(actionId) {
                    EditorInfo.IME_ACTION_SEARCH -> {
                        keyword = binding.inputSearch.text.toString()
                        if (Preferences.token.isNotEmpty()) updateRecentSearchKeyword(Preferences.token, keyword)
                        setAdapter()
                        return false
                    }
                }
                return true
            })

            // Layout Player
            videoView.videoSurfaceView?.setOnClickListener { onBackPressed() }
        }
    }

    fun setBottomInfo(): Long? {
        return mPlayer?.currentPosition
    }

    private fun updateRecentSearchKeyword(token: String, keyword: String?) {
        Log.d(TAG, "updateRecentSearchKeyword()")
        RetrofitClient.getService().updateRecentKeyword(token, keyword).enqueue( object :
            Callback<Map<String, Any>> {
            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(
                call: Call<Map<String, Any>>,
                response: Response<Map<String, Any>>
            ) {
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.i(TAG, "update onResponse Body => ${response.body()}")
                    }
                }
                else Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
            }
        })
    }

    companion object {
        private val TAG = SearchResultActivity::class.java.simpleName
        lateinit var listData: NoteLiveDataModel
        private const val TRIM_ON_RESET = true // 할당 자 재설정시 메모리 해제 여부. 할당자가 여러 플레이어 인스턴스에서 재사용되지 않는 한 참이어야 합니다.
        private const val INDIVIDUAL_ALLOCATION_SIZE = 16 // 각 Allocation 의 길이
        private const val TARGET_BUFFER_BYTES = -1 // 대상 버퍼 크기 : 바이트 단위
        private const val PRIORITIZE_TIME_OVER_SIZE_THRESHOLDS = true // 부하 제어가 버퍼 크기 제약보다 버퍼 시간 제약을 우선시하는지 여부
        private const val MIN_BUFFER_DURATION = 2000 // 플레이어가 항상 버퍼링을 시도하는 미디어의 최소 기간 : 2초
        private const val MAX_BUFFER_DURATION = 5000 // 플레이어가 버퍼링을 시도하는 미디어의 최대 기간 : 5초
        private const val PLAYBACK_START_BUFFER_DURATION  = 1500 // 탐색과 같은 사용자 작업 후 재생을 시작하거나 다시 시작하기 위해 버퍼링해야하는 미디어의 지속 시간 : 1.5초
        private const val PLAYBACK_RESUME_BUFFER_DURATION = 2000 // 리 버퍼 후 재생을 재개하기 위해 버퍼링해야하는 미디어의 기본 기간 : 2초
    }
}