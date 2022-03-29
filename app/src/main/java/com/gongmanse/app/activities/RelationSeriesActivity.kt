@file:Suppress("DEPRECATION")

package com.gongmanse.app.activities

import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.View
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.RelationSeriesRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityRelationSeriesBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.model.VideoPlayer
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.GBLog
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.upstream.DefaultAllocator
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class RelationSeriesActivity : AppCompatActivity(), SwipeRefreshLayout.OnRefreshListener, View.OnClickListener {

    private lateinit var binding: ActivityRelationSeriesBinding
    private lateinit var mAdapter: RelationSeriesRVAdapter
    private lateinit var query: HashMap<String, String>
    private lateinit var scrollListener: EndlessRVScrollListener
    private val linearLayoutManager = LinearLayoutManager(this)
    private var videoPlayer: VideoPlayer? = null
    private var seriesId: String? = null
    private var bottomVideoId : String? = null
    private var title : String? = null
    private var position : Long = 0
    private var url : String? = null
    private var teacher : String? = null
    private var mOffset = 0
    private var videoId : String? =null
    private var isLoading = false
    private var isPlay = false
    private var bottomListPosition :Int? = null
    private var sorting : Int? = null
    private var bottomSeriesId : String? = null
    private var bottomSubjectId : Int? = null
    private var bottomGrade : String? = null
    private var bottomSorting : Int = Constants.CONTENT_RESPONSE_VALUE_LATEST
    private var bottomKeyword : String? = null
    private var queryType : Int? = null
    private var mPlayer: SimpleExoPlayer? = null
    private lateinit var bottomQuery: HashMap<String, Any?>
    private val videoIds: MutableList<String> = mutableListOf()
    override fun onRefresh() {
        mAdapter.clear()
        videoIds.clear()
        binding.recyclerView.pausePlayer()
        initView()
        binding.layoutRefresh.isRefreshing = false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_relation_series)
        loadExtraData()
        initView()

        binding.recyclerView.isPiPOn = true
    }

    override fun onResume() {
        super.onResume()
        videoPlayer?.position?.let {
            if (it == -1L) {
                pause()
                binding.icPlay.isClickable = false
            } else {
                resume()
            }
        }
    }

    override fun onPause() {
        GBLog.i("TAG","onPause")
        binding.recyclerView.pausePlayer()

        super.onPause()
    }

    override fun onDestroy() {
        GBLog.i("TAG","onDestroy")
        binding.recyclerView.releasePlayer()
        super.onDestroy()
    }

    override fun onStop() {
        super.onStop()
        pause()
    }

    override fun onBackPressed() {
        backToVideo()
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            // 홈버튼 버튼 (뒤로가기)
            android.R.id.home -> onBackPressed()
            // 창 닫기
            R.id.btn_close -> onBackPressed()
            // 플레이어 닫기
            R.id.ic_close -> playerClose()
            // 플레이어 재생
            R.id.ic_play -> resume()
            // 플레이어 일시정지
            R.id.ic_pause -> pause()
//            // 플레이어 돌아가기
//            R.id.videoView -> onBackPressed()
        }
    }
    // 인텐트 데이터 수집
    private fun loadExtraData() {
        // 시리즈 ID
        if (intent.hasExtra(Constants.EXTRA_KEY_SERIES_ID)) {
            seriesId = intent.getStringExtra(Constants.EXTRA_KEY_SERIES_ID)
        }
        // PIP Video URL
        if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_URL)) {
            url = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_URL)
        }
        // PIP Video Now Position
        if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_POSITION)) {
            position = intent.getLongExtra(Constants.EXTRA_KEY_VIDEO_POSITION, 0)
        }
        // PIP Video Title
        if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_TITLE)) {
            title = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_TITLE)
        }
        // PIP Video Teacher Name
        if (intent.hasExtra(Constants.EXTRA_KEY_TEACHER_NAME)) {
            teacher = intent.getStringExtra(Constants.EXTRA_KEY_TEACHER_NAME)
        }
        // PIP Video ID
        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_VIDEO_ID)) {
            bottomVideoId = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_VIDEO_ID)
        }
        // PIP Series ID
        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID)) {
            bottomSeriesId = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID)
        }
        // PIP Subject ID
        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID)) {
            bottomSubjectId = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID, 0).let {
                if (it == 0) null else it
            }
        }
        // PIP Grade
        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_GRADE)) {
            bottomGrade = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_GRADE)
        }
        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_SORTING)) {
            bottomSorting = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, Constants.CONTENT_RESPONSE_VALUE_LATEST)
        }
        // PIP Keyword
        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD)) {
            bottomKeyword = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD)
        }
        // PIP Video QueryType
        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE)) {
            queryType = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE, 0)
        }
        // PIP Video Sorting
        if (intent.hasExtra(Constants.EXTRA_KEY_SORTING)) {
            sorting = intent.getIntExtra(Constants.EXTRA_KEY_SORTING, 0)
        }
        // PIP Video Now Position
        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION)) {
            bottomListPosition = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION, 0)
        }

        videoPlayer = if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_PLAYER)){
            intent.getSerializableExtra(Constants.EXTRA_KEY_VIDEO_PLAYER) as VideoPlayer
        } else {
            VideoPlayer(bottomVideoId, bottomVideoId, title, teacher, url, position)
        }

        Log.d(TAG,"videoPlayer => $videoPlayer")
        Log.d("mVideoViewModel","$seriesId")
    }

    private fun initView() {
        if (videoPlayer != null) {
            binding.setVariable(BR.player, videoPlayer)
        }
        binding.layoutRefresh.setOnRefreshListener(this)
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_series)
        binding.layoutTitleUnit.title = Constants.ACTIONBAR_TITLE_RELATION_SERIES
        binding.layoutAutoLayer.swAutoPlay.setOnCheckedChangeListener { _, isChecked ->
            if (::mAdapter.isInitialized) {
                mAdapter.setAutoPlay(isChecked)
            }
        }
        binding.layoutAutoLayer.swAutoPlay.isChecked = true
        initRVLayout()
        prepareData()
        passBottomQuery()
        binding.videoView.videoSurfaceView?.setOnClickListener {
            onBackPressed()
        }
        videoPlayer?.videoURL?.let { initPlayer(Uri.parse(it)) }
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<VideoData>()
        mAdapter = RelationSeriesRVAdapter(this).apply {
            clear()
            setSeriesId(seriesId?.toInt() ?: bottomSeriesId?.toInt()!!)
            addItems(items)
        }
        binding.recyclerView.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun listener(query: HashMap<String, String>) {
        RetrofitClient.getService().getSeriesList(seriesId?.toInt()!!, query[Constants.REQUEST_KEY_OFFSET]?.toInt()!!,Constants.LIMIT_DEFAULT).enqueue(object: Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<VideoList>, response: Response<VideoList>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.d(TAG, "onResponse => $this")
                        if (isLoading) {
                            mAdapter.removeLoading()
                        }
                        this.data?.let {
                            if (it.size > 0) {
                                binding.setVariable(BR.data, this)
                                mAdapter.addItems(it)

                                // set recyclerView's videoIds
                                it.map { data ->
                                    videoIds.add(data.id!!)
                                }
                                binding.recyclerView.videoIds = videoIds
                            }
                        }
                        isLoading = false
                    }
                }
            }
        })
    }

    private fun prepareData() {
        // 최초 호출
        Log.d(TAG, "prepareData...")
        query = hashMapOf(Constants.REQUEST_KEY_OFFSET to Constants.OFFSET_DEFAULT, Constants.REQUEST_KEY_LIMIT to Constants.LIMIT_DEFAULT)
        listener(query)
        // 스크롤 이벤트
        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if (!isLoading && mOffset != totalItemsCount && totalItemsCount >= 20) {
                    isLoading = true
                    loadMoreData(totalItemsCount)
                }
            }
        }
        // 스크롤 이벤트 초기화
        binding.recyclerView.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }
    private fun passBottomQuery(){
        if(videoPlayer!!.videoURL == null){
            bottomQuery = hashMapOf(
                Constants.EXTRA_KEY_VIDEO_URL to null
            )
        }else{
            bottomQuery = hashMapOf(
                    Constants.EXTRA_KEY_VIDEO_ID to videoPlayer?.videoId
                ,   Constants.EXTRA_KEY_VIDEO_POSITION to videoPlayer?.position
                ,   Constants.EXTRA_KEY_VIDEO_URL to videoPlayer?.videoURL
                ,   Constants.EXTRA_KEY_VIDEO_TITLE to videoPlayer?.title
                ,   Constants.EXTRA_KEY_TEACHER_NAME to videoPlayer?.teacherName
            )
            mAdapter.addBottomInfo(bottomQuery)
        }
    }

    private fun loadMoreData(offset: Int) {
        // 로딩 화면
        if (isLoading) {
            binding.recyclerView.post {
                mAdapter.addLoading()
            }
        }
        Handler().postDelayed({
            mOffset = offset
            query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
            listener(query)
        }, Constants.ENDLESS_DELAY_VALUE)
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
            videoPlayer?.position?.let {
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
        videoPlayer?.position?.let {
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

    // 동영상 재생
    private fun playVideo() {
        if (videoPlayer != null) {
            binding.videoView.apply {
                binding.icPlay.visibility = View.GONE
                binding.icPause.visibility = View.VISIBLE
                isPlay = true
            }
        }
    }

    private fun playerClose() {
        binding.layoutPlayer.visibility = View.GONE
        pause()

        binding.recyclerView.isPiPOn = false
    }

    private fun resume() {
//        binding.videoView.start()
        mPlayer?.playWhenReady = true
        binding.icPlay.visibility = View.GONE
        binding.icPause.visibility = View.VISIBLE
        isPlay = true
    }

    private fun pause() {
//        binding.videoView.pause()
        Log.d(TAG, "@@@@@@@@@@@@@@@@@@@@@@@@ : pause()")
        mPlayer?.playWhenReady = false
        binding.icPlay.visibility = View.VISIBLE
        binding.icPause.visibility = View.GONE
        isPlay = false
    }

    // 플레이어 초기화
    private fun releasePlayer() {
        if (mPlayer != null) {
            Log.d(TAG, "position => releasePlayer()")
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

    // 뒤로가기 - 영상정보 전달
    private fun backToVideo() {
        val mPlayerPosition = mPlayer?.currentPosition
        Log.d(TAG, "mPlayerPosition : $mPlayerPosition")
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_POSITION , mPlayerPosition)
        setResult(Constants.RELATION_RESULT_CODE, intent)
        releasePlayer()
        finish()
    }

    fun backToVideo(id: String?, seriesId: String?, listPosition: Int, isAutoPlay:Boolean) {
        //click item
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID ,id)
        intent.putExtra(Constants.EXTRA_KEY_SERIES_ID ,seriesId)
        intent.putExtra(Constants.EXTRA_KEY_POSITION , listPosition)
        intent.putExtra(Constants.EXTRA_KEY_IS_AUTO , isAutoPlay)
        intent.putExtra(Constants.EXTRA_KEY_QUERY,Constants.QUERY_TYPE_SERIES)
        //bottom
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_VIDEO_ID ,bottomVideoId)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID, bottomSeriesId)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID, bottomSubjectId)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_GRADE, bottomGrade)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, bottomSorting)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD, bottomKeyword)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_URL, url)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_POSITION, position)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_TITLE, title)
        intent.putExtra(Constants.EXTRA_KEY_TEACHER_NAME, teacher)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE, queryType)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION, bottomListPosition)
        intent.putExtra(Constants.EXTRA_KEY_SORTING, sorting)

        Log.v("backToVideo","return backToVideo =>$bottomVideoId $bottomSeriesId $bottomSubjectId $bottomGrade $bottomSorting $bottomKeyword $queryType $bottomListPosition $sorting ")
        setResult(RESULT_OK, intent)
        releasePlayer()
        finish()
    }

    companion object {
        private val TAG = RelationSeriesActivity::class.java.simpleName
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