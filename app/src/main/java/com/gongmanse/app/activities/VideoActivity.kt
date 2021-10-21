@file:Suppress("DEPRECATION")

package com.gongmanse.app.activities

import android.app.Activity
import android.app.Dialog
import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.media.MediaPlayer
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.text.style.ForegroundColorSpan
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.share.Sharer
import com.facebook.share.model.ShareLinkContent
import com.facebook.share.widget.ShareDialog
import com.gongmanse.app.R
import com.gongmanse.app.adapter.ViewPagerAdapter
import com.gongmanse.app.adapter.video.HashTagRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.api.video.VideoRepository
import com.gongmanse.app.databinding.ActivityVideoBinding
import com.gongmanse.app.databinding.DialogVideoRatingBinding
import com.gongmanse.app.databinding.DialogVideoShareBinding
import com.gongmanse.app.fragments.sheet.SelectionSheetVideoOption
import com.gongmanse.app.fragments.sheet.SelectionSheetVideoPlaySpeed
import com.gongmanse.app.fragments.video.*
import com.gongmanse.app.listeners.OnVideoOptionListener
import com.gongmanse.app.model.*
import com.gongmanse.app.model.VideoViewModel
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.GBLog
import com.gongmanse.app.utils.Preferences
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.extractor.DefaultExtractorsFactory
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.source.MergingMediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.SingleSampleMediaSource
import com.google.android.exoplayer2.text.TextOutput
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.ui.AspectRatioFrameLayout
import com.google.android.exoplayer2.upstream.DataSpec
import com.google.android.exoplayer2.upstream.DefaultAllocator
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.upstream.RawResourceDataSource
import com.google.android.exoplayer2.util.MimeTypes
import com.google.android.exoplayer2.util.Util
import com.google.android.material.tabs.TabLayout
import com.kakao.sdk.common.KakaoSdk
import com.kakao.sdk.link.LinkClient
import com.kakao.sdk.template.model.*
import kotlinx.android.synthetic.main.activity_video.*
import kotlinx.android.synthetic.main.dialog_video_share.*
import kotlinx.android.synthetic.main.fragment_video_qnas.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import okhttp3.ResponseBody
import org.jetbrains.anko.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*

class VideoActivity : AppCompatActivity(), View.OnClickListener {

    private lateinit var binding: ActivityVideoBinding
    private lateinit var mVPAdapter: ViewPagerAdapter
    private lateinit var mHashTagRVAdapter: HashTagRVAdapter
    private lateinit var noteFragment: VideoNoteFragment1
    private lateinit var qnaFragment: VideoQNASFragment
    private lateinit var playListFragment: VideoPlayListFragment1
    lateinit var mVideoViewModel: VideoViewModel

    private lateinit var ratingDialog: Dialog
    private lateinit var shareDialog: Dialog

    private lateinit var optionSheet: SelectionSheetVideoOption
    private lateinit var playSpeedSheet: SelectionSheetVideoPlaySpeed

    private lateinit var mPlayerCaptionButton: ImageButton
    private lateinit var mPlayerFullScreenButton: ImageView

    private lateinit var mMediaPlayer: MediaPlayer

    private var mPlayer: SimpleExoPlayer? = null
    private var mPosition: Int = 0
    private var mPlayerPosition : Long = 0
    private var mPlayerBottomPosition : Long = 0
    private var mPlayerSpeed: Int = SelectionSheetVideoPlaySpeed.OPTION_SPEED_DEFAULT

    private var isBottom: Boolean = false
    private var isFirst: Boolean = true
    private var callbackManager: CallbackManager? = null
    private var isFullScreen = false
    private var isOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
    private var isTablet = false

    private val intro = arrayOf(R.raw.gong_intro1, R.raw.gong_intro2)
    private val outro = arrayOf(R.raw.gong_outro1, R.raw.gong_outro2)
    private var videoIntro: Int = intro[Random().nextInt(intro.size)]
    private var videoOutro: Int = outro[Random().nextInt(outro.size)]

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        Log.v(TAG, "onConfigurationChanged")
        setConfigurationLayout(newConfig.orientation == Configuration.ORIENTATION_PORTRAIT)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        isTablet = Constants.isTablet(this)
        hasExpireCheck()
    }

    override fun onResume() {
        super.onResume()
        if (mPlayerPosition != -1L) {
            startPlayer()
        } else {
            pausePlayer()
        }
    }

    override fun onStop() {
        super.onStop()
        pausePlayer()
    }

    override fun onDestroy() {
        super.onDestroy()
        releasePlayer()
    }

    override fun onBackPressed() {
        if (intent.hasExtra(Constants.EXTRA_KEY_BACK_PRESSED)) {
            setResult(RESULT_OK)
            finish()
        } else {
            finish()
        }
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            // ExoPlayer 컨트롤러 : 닫기
            R.id.exo_close -> finish()
            // ExoPlayer 컨트롤러 : 자막
            R.id.exo_caption -> onPlayerCaption()
            // ExoPlayer 컨트롤러 : 더보기
            R.id.exo_more -> showMoreView()
            // ExoPlayer 컨트롤러 : 최대화 or 최소화
            R.id.exo_fullscreen_icon -> setPlayerFullScreen()
            // 재시작
            R.id.btn_replay -> reloadPlayer()
            // 정보창 업 or 다운 버튼
            R.id.btn_sliding -> onSlideUpDown()
            // 평점
            R.id.btn_rating, R.id.btn_rating2 -> showRatingDialog()
            // 공유
            R.id.btn_share, R.id.btn_share2 -> showShareDialog()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        callbackManager?.onActivityResult(requestCode, resultCode, data)
    }

    private fun hasExpireCheck() {
        if (intent.hasExtra(Constants.EXTRA_KEY_TYPE)) {
            val type = intent.getIntExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_SERIES)
            if (type == Constants.QUERY_TYPE_BEST || Commons.hasExpire()) {
                KakaoSdk.init(this, getString(R.string.kakao_app_key)) // Kakao AppKey 초기화
                bindUI()
            } else {
                showTicketToast()
            }
        } else {
            if (Commons.hasExpire()) {
                KakaoSdk.init(this, getString(R.string.kakao_app_key)) // Kakao AppKey 초기화
                bindUI()
            } else {
                showTicketToast()
            }
        }
    }

    private fun bindUI() {
        binding = ActivityVideoBinding.inflate(layoutInflater).apply {
               this@VideoActivity.let { context ->
                   val mVideoViewModelFactory = VideoViewModelFactory(VideoRepository())
                   mVideoViewModel = ViewModelProvider(context, mVideoViewModelFactory).get(
                       VideoViewModel::class.java
                   )
                   viewModel = mVideoViewModel
                   lifecycleOwner = this@VideoActivity
               }
        }
        CoroutineScope(Dispatchers.Main).launch {
            setContentView(binding.root)
            binding.tvSubtitle.textSize = if (Constants.isTablet(this@VideoActivity)) 18F else 14F
            setConfigurationLayout(resources.configuration.orientation == ActivityInfo.SCREEN_ORIENTATION_PORTRAIT)
            setHashTagRVLayout()
            setViewPager()
            getViewModel()
            getExtraData()
        }
    }

    private fun getViewModel() {
        mVideoViewModel.showLoginToast.observe(this, {
            it.getContentIfNotHandled()?.let {
                showLoginAlert()
            }
        })

        mVideoViewModel.showToast.observe(this, {
            it.getContentIfNotHandled()?.let { msg ->
                showToast(msg)
            }
        })

        mVideoViewModel.moveActivity.observe(this, {
            it.getContentIfNotHandled()?.let {
                moveSeriesActivity()
            }
        })

        mVideoViewModel.moveCommentary.observe(this, {
            it.getContentIfNotHandled()?.let { isCommentary ->
                Log.v(TAG, "moveCommentary => $isCommentary")
                Handler(Looper.getMainLooper()).postDelayed({
                    if (Preferences.token.isNotEmpty()) {
                        mVideoViewModel.playListOffset.value = Constants.OFFSET_DEFAULT_INT
                        playListFragment.initIsNext()
                        mVideoViewModel.loadPlayList()
                    }
                }, 300L)
            }
        })

        mVideoViewModel.videoId.observe(this, {
            Log.v(TAG, "getViewModel videoId => $it")
            resetVideo()
            onSlideClose()
            qnaFragment.clearAdapter()
            if (mVideoViewModel.playListType.value == Constants.QUERY_TYPE_BEST && isFirst) {
                Log.v(TAG, "hasExpire => ${Commons.hasExpire()} || isFirst => $isFirst")
                if (isFirst) {
                    mVideoViewModel.loadBest()
                    isFirst = false
                } else {
                    showTicketToast()
                }
            } else {
                mVideoViewModel.load()
            }
            mVideoViewModel.offsetQNA.value = Constants.OFFSET_DEFAULT
            mVideoViewModel.getQNAContents()
            mVideoViewModel.initNoteData(it)
        })

        mVideoViewModel.videoMode.observe(this, {
            when (it) {
                Constants.VIDEO_INTRO -> {
                    mVideoViewModel.useCaption.postValue(false)
                    mVideoViewModel.useOutro.postValue(false)
                    setupPlayIntro(videoIntro)
                }
                Constants.VIDEO_PLAY -> {
                    mVideoViewModel.useCaption.postValue(Preferences.subtitle)
                    setupPlayVideo()
                    mPlayer?.seekTo(mPlayerBottomPosition)
                    if (mPlayerBottomPosition == -1L) {
                        mVideoViewModel.videoMode.postValue(Constants.VIDEO_OUTRO)
                    }
                }
                Constants.VIDEO_OUTRO -> {
                    mVideoViewModel.useCaption.postValue(false)
                    mVideoViewModel.useOutro.postValue(true)
                    setupPlayIntro(videoOutro)
                }
            }
        })

        mVideoViewModel.useCaption.observe(this, {
            binding.useCaption = it

            Log.d(TAG, "isTabletCheck : $isTablet")
            val drawable = if (it == true) {
//                if (isTablet) ContextCompat.getDrawable(this@VideoActivity, R.drawable.ic_small_caption_on_42dp)
//                else ContextCompat.getDrawable(this@VideoActivity, R.drawable.ic_small_caption_on)
                ContextCompat.getDrawable(this@VideoActivity, R.drawable.ic_small_caption_on)
            } else {
//                if (isTablet) ContextCompat.getDrawable(this@VideoActivity, R.drawable.ic_small_caption_off_42dp)
//                else ContextCompat.getDrawable(this@VideoActivity, R.drawable.ic_small_caption_off)
                ContextCompat.getDrawable(this@VideoActivity, R.drawable.ic_small_caption_off)
            }
            if (::mPlayerCaptionButton.isInitialized) {
                mPlayerCaptionButton.setImageDrawable(drawable)
            }
        })
    }

    private fun resetVideo() {
        if (::ratingDialog.isInitialized) ratingDialog.dismiss()
        if (::shareDialog.isInitialized) shareDialog.dismiss()
        mPlayerBottomPosition = 0L
        mPlayerPosition = 0L
        releasePlayer()
        binding.tvSubtitle.text = ""
        mPlayerSpeed = SelectionSheetVideoPlaySpeed.OPTION_SPEED_DEFAULT
        if (isBottom.not()) {
            mVideoViewModel.videoMode.postValue(Constants.VIDEO_INTRO)
        }
        mVideoViewModel.useCaption.postValue(false)
        mVideoViewModel.useOutro.postValue(false)

        setVideoPlayer()
        if (isBottom) {
            Handler(Looper.getMainLooper()).postDelayed({
                Log.d(TAG, "@@@@@@@@@ : 2. Constants.VIDEO_PLAY")
                mVideoViewModel.videoMode.postValue(Constants.VIDEO_PLAY)
                isBottom = false
            }, 500L)
        }
    }

    // 인텐트 데이터 수집
    private fun getExtraData() {
        mVideoViewModel.playListOffset.value = Constants.OFFSET_DEFAULT_INT
        // Query Type
        if (intent.hasExtra(Constants.EXTRA_KEY_TYPE)) {
            intent.getIntExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_SERIES).let { id ->
                Log.v(TAG, "PlayListType => $id")
                mVideoViewModel.playListType.value = id
            }
        } else {
            mVideoViewModel.playListType.value = Constants.QUERY_TYPE_SERIES
        }

        // Video Id
        if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_ID)) {
            intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_ID).let { id ->
                Log.v(TAG, "VideoID => $id")
                mVideoViewModel.videoId.value = id
            }
        }

        // Series Id
        if (intent.hasExtra(Constants.EXTRA_KEY_SERIES_ID)) {
            intent.getStringExtra(Constants.EXTRA_KEY_SERIES_ID).let { id ->
                Log.v(TAG, "SeriesID => $id")
                mVideoViewModel.seriesId.value = id
            }
        }

        // Sorting
        if (intent.hasExtra(Constants.EXTRA_KEY_SORTING)) {
            intent.getIntExtra(Constants.EXTRA_KEY_SORTING, Constants.CONTENT_RESPONSE_VALUE_LATEST).let { id ->
                Log.v(TAG, "Sorting => $id")
                mVideoViewModel.sorting.value = id
            }
        } else {
            mVideoViewModel.sorting.value = Constants.CONTENT_RESPONSE_VALUE_LATEST
        }

        // List Position
        if (intent.hasExtra(Constants.EXTRA_KEY_NOW_POSITION)) {
            intent.getIntExtra(Constants.EXTRA_KEY_NOW_POSITION, 0).let { id ->
                Log.v(TAG, "NowPosition => $id")
                mVideoViewModel.playListNowPosition.value = if (mVideoViewModel.sorting.value == 4 && mVideoViewModel.playListType.value == Constants.QUERY_TYPE_RECENT_VIDEO) 0 else id
                Handler(Looper.getMainLooper()).postDelayed({
                    if (Preferences.token.isNotEmpty()) {
                        mVideoViewModel.loadPlayList()
                    }
                }, 300L)
            }
        } else {
            mVideoViewModel.getNowPosition()
        }

        // PIP info
        if(intent.hasExtra(Constants.EXTRA_KEY_VIDEO_URL)){
            mVideoViewModel.bottomURL.value = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_URL)
            mVideoViewModel.bottomPosition.value = intent.getLongExtra(
                Constants.EXTRA_KEY_POSITION,
                0
            )
            mVideoViewModel.bottomTeacherName.value = intent.getStringExtra(Constants.EXTRA_KEY_TEACHER_NAME)
            mVideoViewModel.bottomTitle.value = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_TITLE)
        }

        // Search info
        if(intent.hasExtra(Constants.EXTRA_KEY_KEYWORD)) {
            intent.getStringExtra(Constants.EXTRA_KEY_KEYWORD).let { id ->
                Log.v(TAG, "Keyword => $id")
                mVideoViewModel.keyword.value = id
            }
        }

        if(intent.hasExtra(Constants.EXTRA_KEY_JINDO_ID)) {
            intent.getStringExtra(Constants.EXTRA_KEY_JINDO_ID).let { id ->
                Log.v(TAG, "JindoId => $id")
                mVideoViewModel.jindoId.value = id?.toInt()
            }
        }

        if(intent.hasExtra(Constants.EXTRA_KEY_GRADE)) {
            intent.getStringExtra(Constants.EXTRA_KEY_GRADE).let { id ->
                Log.v(TAG, "Grade => $id")
                mVideoViewModel.grade.value = id
            }
        }

        if(intent.hasExtra(Constants.EXTRA_KEY_SUBJECT_ID)) {
            intent.getIntExtra(Constants.EXTRA_KEY_SUBJECT_ID, 0).let { id ->
                Log.v(TAG, "SubjectId => $id")
                mVideoViewModel.subjectId.value = if (id == 0) null else id
            }
        }

        if (intent.hasExtra(Constants.EXTRA_KEY_TAB_POSITION)) {
            intent.getIntExtra(Constants.EXTRA_KEY_TAB_POSITION, 0).let { position ->
                binding.tabLayout.getTabAt(position)?.select()
            }
        }
    }

    private fun setViewPager(){
        noteFragment = VideoNoteFragment1.newInstance()
        qnaFragment = VideoQNASFragment.newInstance()
        playListFragment = VideoPlayListFragment1.newInstance()
        mVPAdapter = ViewPagerAdapter(supportFragmentManager, lifecycle).apply {
            addFragment(noteFragment)
            addFragment(qnaFragment)
            addFragment(playListFragment)
        }
        binding.viewPager.apply {
            adapter = mVPAdapter
            offscreenPageLimit = 3
            isUserInputEnabled = false
        }
        binding.tabLayout.apply {
            addOnTabSelectedListener(onTabSelectedListener)
            getTabAt(mPosition)?.select()
        }
    }

    private fun setVideoPlayer() {
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
            addListener(onPlayerEventListener) // 플레이어에서 이벤트를 수신
            addTextOutput(onTextOutputListener) // 출력을 등록하여 텍스트 이벤트를 수신
        }
        // PlayerView 설정
        binding.playerView.apply {
            player = mPlayer // player 연결
            useController = false // 컨트롤러 사용 안함
            resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
            subtitleView?.visibility = View.GONE // 내장 subtitleView 숨김
            setShutterBackgroundColor(Color.TRANSPARENT) // exo_shutter 투명처리 : 동영상을 숨겨야 할 때 표시되는 보기
            // ExoPlayer 커스텀 컨트롤러 클릭 리스너 연결
            findViewById<ImageButton>(R.id.exo_close).setOnClickListener(this@VideoActivity) // ExoPlayer 컨트롤러 : 닫기
            findViewById<ImageButton>(R.id.exo_more).setOnClickListener(this@VideoActivity) // ExoPlayer 컨트롤러 : 더보기
            mPlayerCaptionButton = findViewById<ImageButton>(R.id.exo_caption).apply { // ExoPlayer 컨트롤러 : 자막
                setOnClickListener(this@VideoActivity)
            }
            mPlayerFullScreenButton = findViewById<ImageView>(R.id.exo_fullscreen_icon).apply {
                setOnClickListener(this@VideoActivity) // ExoPlayer 컨트롤러 : 최소화/최대화
            }
            videoIntro = intro[Random().nextInt(RANDOM_MAXIMUM_VALUE - RANDOM_MINIMUM_VALUE + 1) + RANDOM_MINIMUM_VALUE]
            videoOutro = outro[Random().nextInt(RANDOM_MAXIMUM_VALUE - RANDOM_MINIMUM_VALUE + 1) + RANDOM_MINIMUM_VALUE]
            if (isBottom.not()) {
                when (mVideoViewModel.videoMode.value) {
                    Constants.VIDEO_INTRO -> setupPlayIntro(videoIntro)
                    Constants.VIDEO_PLAY -> setupPlayVideo()
                    Constants.VIDEO_OUTRO -> setupPlayIntro(videoOutro)
                }
            }
        }
    }

    private fun setHashTagRVLayout() {
        mHashTagRVAdapter = HashTagRVAdapter(this).apply {
            val items = ObservableArrayList<String>()
            addItems(items)
        }
        binding.rvHashTag.apply {
            adapter = mHashTagRVAdapter
            layoutManager = LinearLayoutManager(this@VideoActivity).apply {
                orientation = LinearLayoutManager.HORIZONTAL
            }
        }
        binding.rvHashTag2.apply {
            adapter = mHashTagRVAdapter
            layoutManager = LinearLayoutManager(this@VideoActivity).apply {
                orientation = LinearLayoutManager.HORIZONTAL
            }
        }
    }

    // 자막
    private fun onPlayerCaption() {
        mVideoViewModel.useCaption.value = mVideoViewModel.useCaption.value?.not()
    }

    // 더보기 기능
    private fun showMoreView() {
        optionSheet = SelectionSheetVideoOption(
            onOptionSheetCallback,
            binding.useCaption == true,
            mPlayerSpeed
        ).apply {
            show(supportFragmentManager, tag)
        }
    }

    private val onOptionSheetCallback = object : OnVideoOptionListener {
        override fun selectionOption(value: Int) {
            if (value == 0) {
                onPlayerCaption()
            } else {
                optionSheet.dismiss()
                playSpeedSheet = SelectionSheetVideoPlaySpeed(this, mPlayerSpeed).apply {
                    show(supportFragmentManager, tag)
                }
            }
        }

        override fun selectionPlaySpeed(value: Int) {
            playSpeedSheet.dismiss()
            mPlayerSpeed = value
            setPlayerSpeed()
        }
    }

    private fun setPlayerSpeed() {
        when (mPlayerSpeed) {
            SelectionSheetVideoPlaySpeed.OPTION_SPEED_DEFAULT -> mPlayer?.setPlaybackParameters(
                PlaybackParameters.DEFAULT
            )
            SelectionSheetVideoPlaySpeed.OPTION_SPEED_15 -> mPlayer?.setPlaybackParameters(
                PlaybackParameters(1.5f)
            )
            SelectionSheetVideoPlaySpeed.OPTION_SPEED_125 -> mPlayer?.setPlaybackParameters(
                PlaybackParameters(1.25f)
            )
            SelectionSheetVideoPlaySpeed.OPTION_SPEED_075 -> mPlayer?.setPlaybackParameters(
                PlaybackParameters(0.75f)
            )
            SelectionSheetVideoPlaySpeed.OPTION_SPEED_05 -> mPlayer?.setPlaybackParameters(
                PlaybackParameters(0.5f)
            )
        }
    }

    // 정보창 슬라이드 업/다운
    private fun onSlideUpDown() {
        Log.v(TAG, "onSlideUpDown")
        binding.layoutSlidingContent.let {
            if (it.visibility == View.VISIBLE) {
                it.visibility = View.GONE
            } else {
                qnaFragment.hideSoftKeyboard()
                Handler(Looper.getMainLooper()).postDelayed({
                    it.visibility = View.VISIBLE
                }, 300L)

            }
        }
    }

    // 정보창 슬라이드 닫기
    fun onSlideClose() {
        Log.v(TAG, "onSlideClose")
        binding.layoutSlidingContent.visibility = View.GONE
    }

    // 플레이어 최대화/최소화
    private fun setPlayerFullScreen() {
        val params1 = binding.player.layoutParams
        if (isFullScreen) {
            requestedOrientation = if (isOrientation == ActivityInfo.SCREEN_ORIENTATION_PORTRAIT) { // 세로
                ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            } else {
                ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
            }
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR
            mPlayerFullScreenButton.setImageDrawable(
                ContextCompat.getDrawable(
                    this,
                    R.drawable.exo_controls_fullscreen_enter
                )
            )
            params1.width = 0
            params1.height = 0
            binding.tvSubtitle.textSize = if (Constants.isTablet(this)) 18F else 14F

            val timeBar = binding.playerView.findViewById<LinearLayout>(R.id.layout_time_bar)
            val timeBarParams = (timeBar.layoutParams as ConstraintLayout.LayoutParams)
            timeBarParams.bottomMargin = if (Constants.isTablet(this)) Constants.dpToPx(this, 55) else Constants.dpToPx(this, 30)
            timeBar.layoutParams = timeBarParams

        } else {
            isOrientation = resources.configuration.orientation
            Log.v(TAG, "isOrientation => $isOrientation")

            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
            mPlayerFullScreenButton.setImageDrawable(
                ContextCompat.getDrawable(
                    this,
                    R.drawable.exo_controls_fullscreen_exit
                )
            )
            params1.width = ViewGroup.LayoutParams.MATCH_PARENT
            params1.height = ViewGroup.LayoutParams.MATCH_PARENT
            binding.tvSubtitle.textSize = if (Constants.isTablet(this)) 24F else 20F

            val timeBar = binding.playerView.findViewById<LinearLayout>(R.id.layout_time_bar)
            val timeBarParams = (timeBar.layoutParams as ConstraintLayout.LayoutParams)
            timeBarParams.bottomMargin = if (Constants.isTablet(this)) Constants.dpToPx(this, 65) else Constants.dpToPx(this, 35)
            timeBar.layoutParams = timeBarParams

        }
        binding.player.layoutParams = params1
        isFullScreen = isFullScreen.not()
    }

    private fun setConfigurationLayout(isPortrait: Boolean) {
        if (isFullScreen.not()) {
            if (isPortrait) {
                Log.v(TAG, "ORIENTATION_PORTRAIT")
                val constraints = ConstraintSet()
                constraints.clone(binding.rootLayout)
                constraints.connect(binding.playerLayout.id, ConstraintSet.END, binding.rootLayout.id, ConstraintSet.END)
                constraints.connect(binding.contentLayout.id, ConstraintSet.START, binding.rootLayout.id, ConstraintSet.START)
                constraints.connect(binding.contentLayout.id, ConstraintSet.TOP, binding.playerLayout.id, ConstraintSet.BOTTOM)
                constraints.applyTo(binding.rootLayout)
            } else {
                Log.v(TAG, "ORIENTATION_LANDSCAPE")
                val constraints = ConstraintSet()
                constraints.clone(binding.rootLayout)
                constraints.connect(binding.playerLayout.id, ConstraintSet.END, binding.contentLayout.id, ConstraintSet.START)
                constraints.connect(binding.infoLayout.id, ConstraintSet.END, binding.contentLayout.id, ConstraintSet.START)
                constraints.connect(binding.contentLayout.id, ConstraintSet.START, binding.playerLayout.id, ConstraintSet.END)
                constraints.connect(binding.contentLayout.id, ConstraintSet.TOP, binding.rootLayout.id, ConstraintSet.TOP)
                constraints.applyTo(binding.rootLayout)
            }
            binding.infoLayout.visibility = if (isPortrait) View.GONE else View.VISIBLE
            binding.layoutSlidingHandle.visibility = if (isPortrait) View.VISIBLE else View.GONE
            binding.layoutSlidingContent.visibility = View.GONE
            Handler(Looper.getMainLooper()).postDelayed({
                binding.tabLayout.getTabAt(mPosition.plus(1) % 3)?.select()
            }, 100L)
            Handler(Looper.getMainLooper()).postDelayed({
                binding.tabLayout.getTabAt(mPosition.plus(2) % 3)?.select()
            }, 100L)
//            if (::noteFragment.isInitialized) {
//                noteFragment.reload()
//            }
        }
    }

    private fun addSubTitleInEventView(str: CharSequence) {
        val ssb = SpannableStringBuilder(str)
        var isHighlightSound = false

        val test = "기준으로 해서 동사가 당한다, 되어진다라고 갈 때는 우리가"
        Log.v(TAG, "test => ${ssb.indexOf(test, 0)}")

        mVideoViewModel.data.value?.highlight?.let { it ->
            val highlights = it.split("@")
            highlights.forEach { txt ->
                val highlight = txt.trim()
                val position = ssb.indexOf(highlight, 0)
                if (position != -1) {
                    Log.v(TAG, "test : highlight => $highlight : ${highlight.length}")
                    Log.v(TAG, "test : ssb => $ssb : ${ssb.length}")
                    isHighlightSound = true
                    val index = position.plus(highlight.length)
                    Log.v(TAG, "test : position => $position")
                    Log.v(TAG, "test : index => $index")
                    ssb.setSpan(
                        ForegroundColorSpan(Color.parseColor("#ffff00")),
                        position,
                        index,
                        Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                }
            }
        }

        if (isHighlightSound) {
            Log.d(TAG, "PlayAlarmSound()....")
//            playAlarmSound() // mp3 소리
            isHighlightSound = false
        }

        mVideoViewModel.data.value?.tags?.let { it ->
            val tags = it.split(",")
            tags.forEach { tag ->
                val position = ssb.indexOf(tag)
                if (position != -1) {
                    Log.v(TAG, "tag => $tag")
                    ssb.setSpan(
                        ForegroundColorSpan(ContextCompat.getColor(this, R.color.main_color)),
                        position,
                        position.plus(tag.length),
                        Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                    )
                    ssb.setSpan(object : ClickableSpan() {
                        override fun onClick(widget: View) {
                            Log.v(TAG, "click tag => $tag")
                            setPlayerPosition()
                            val intent = Intent(this@VideoActivity, SearchResultActivity::class.java)
                            Log.e(TAG, "playerPosition : $mPlayerPosition")
                            mVideoViewModel.data.value?.apply {
                                intent.putExtra(Constants.EXTRA_KEY_KEYWORD, tag.substring(1))
                                intent.putExtra(Constants.EXTRA_KEY_VIDEO_URL, videoURL)
                                intent.putExtra(Constants.EXTRA_KEY_VIDEO_POSITION, mPlayerPosition)
                                intent.putExtra(Constants.EXTRA_KEY_VIDEO_TITLE, title)
                                intent.putExtra(Constants.EXTRA_KEY_TEACHER_NAME, teacherName)
                                intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, mVideoViewModel.videoId.value)
                                intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID, mVideoViewModel.seriesId.value)
                                intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID, mVideoViewModel.subjectId.value)
                                intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, mVideoViewModel.sorting.value)
                                intent.putExtra(Constants.EXTRA_KEY_BOTTOM_GRADE, mVideoViewModel.grade.value)
                                intent.putExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD, mVideoViewModel.keyword.value)
                                intent.putExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE, mVideoViewModel.playListType.value)
                                intent.putExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION, mVideoViewModel.playListNowPosition.value)
                            }
                            moveSearchResultView(intent)
                        }
                    }, position, position.plus(tag.length), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
                }
            }
        }
        binding.tvSubtitle.text = ssb
        binding.tvSubtitle.movementMethod = LinkMovementMethod.getInstance()
    }

    private fun playAlarmSound() {
//        val alarm = Uri.parse("android.resource://com.gongmanse.app.activities/${R.raw.alarm}")
//        val rt = RingtoneManager.getRingtone(this, alarm)
//        rt.play()
        CoroutineScope(Dispatchers.Main).launch {
            mMediaPlayer = MediaPlayer.create(this@VideoActivity, R.raw.alarm)
            mMediaPlayer.start()
            delay(3100L)
            mMediaPlayer.release()
        }
    }

    private fun getDefaultDataSourceFactory(): DefaultDataSourceFactory {
        return DefaultDataSourceFactory(
            this, Util.getUserAgent(
                this,
                resources.getString(R.string.app_name)
            )
        )
    }

    // 인트로 동영상 설정
    private fun setupPlayIntro(id: Int) {
        binding.playerView.useController = false
        val tempSource = RawResourceDataSource(this).apply {
            open(DataSpec(RawResourceDataSource.buildRawResourceUri(id)))
        }
        tempSource.uri?.let {
            val source = ProgressiveMediaSource.Factory(getDefaultDataSourceFactory()).createMediaSource(
                it
            )
            mPlayer?.apply {
                prepare(source, true, false)
                startPlayer()
            }
        }
    }

    // 강의 동영상 설정
    private fun setupPlayVideo() {
        Log.v(TAG, "setupPlayVideo")
        binding.playerView.useController = true
        if (mVideoViewModel.data.value?.videoURL.isNullOrEmpty().not()) {
            val subtitleUrl = "${Constants.FILE_DOMAIN}/${mVideoViewModel.data.value?.subtitle}"
            GBLog.v(TAG, "subtitleURL => $subtitleUrl")
            GBLog.v(TAG, "mediaURL => ${mVideoViewModel.data.value?.videoURL}")
            var devUrl = mVideoViewModel.data.value?.videoURL.toString()
            if (devUrl.contains("https://file.gongmanse.com/om/")) {
                devUrl = devUrl.replace("https://file.gongmanse.com/om/", "https://filedev.gongmanse.com/")
            }
            GBLog.v(TAG, "devUrl => $devUrl")
            val subtitleUri = Uri.parse(subtitleUrl)
            val contentMediaSource = ExtractorMediaSource(
                Uri.parse(devUrl),
                getDefaultDataSourceFactory(),
                DefaultExtractorsFactory(),
                Handler(Looper.getMainLooper()),
                null
            )
            val subtitleSource = SingleSampleMediaSource.Factory(getDefaultDataSourceFactory()).createMediaSource(
                subtitleUri, Format.createTextSampleFormat(
                    null,
                    MimeTypes.TEXT_VTT,
                    C.SELECTION_FLAG_FORCED,
                    "en"
                ), C.TIME_UNSET
            )
            val mediaSource = MergingMediaSource(contentMediaSource, subtitleSource)
            mPlayer?.apply {
                prepare(mediaSource, true, false)
                startPlayer()
            }
        } else {
            showTicketToast()
        }
    }

    // 플레이어 시작
    private fun startPlayer() {
        if (::binding.isInitialized) {
            binding.playerView.hideController()
        }
        mPlayer?.playWhenReady = true
    }

    // 플레이어 일시정지
    private fun pausePlayer() {
        mPlayer?.playWhenReady = false
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
            binding.playerView.player = null
        }
    }

    // 플레이어 재시작
    private fun reloadPlayer() {
        binding.tvSubtitle.text = ""
        Log.d(TAG, "@@@@@@ : 3. VIDEOPLAY")
        isBottom = false
        mPlayerBottomPosition = 0L
        mVideoViewModel.videoMode.postValue(Constants.VIDEO_PLAY)
        mVideoViewModel.useCaption.postValue(Preferences.subtitle)
        mVideoViewModel.useOutro.postValue(false)
//        setupPlayVideo()
    }

    private val onTabSelectedListener = object: TabLayout.OnTabSelectedListener {
        override fun onTabUnselected(tab: TabLayout.Tab?) {}
        override fun onTabReselected(tab: TabLayout.Tab?) {}
        override fun onTabSelected(tab: TabLayout.Tab?) {
            tab?.position?.let { position ->
                binding.viewPager.currentItem = position
                mPosition = position
            }
            binding.tabLayout.apply {
                getTabAt(mPosition)?.select()
            }
        }
    }

    private val onTextOutputListener = TextOutput {
        for (c in it) {
            c.text?.let { subtitle ->
                addSubTitleInEventView(subtitle)
            }
        }
    }

    private val onPlayerEventListener = object: Player.EventListener {
        override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
            if (playWhenReady && playbackState == Player.STATE_ENDED) {
                when(mVideoViewModel.videoMode.value) {
                    Constants.VIDEO_INTRO -> {
                        Log.v(TAG, "VIDEO_INTRO END.")
                        mVideoViewModel.videoMode.postValue(Constants.VIDEO_PLAY)
                    }
                    Constants.VIDEO_PLAY -> {
                        Log.v(TAG, "VIDEO_PLAY END.")
                        mPlayerPosition = -1L
                        mVideoViewModel.videoMode.postValue(Constants.VIDEO_OUTRO)
                    }
                    Constants.VIDEO_OUTRO -> {
                        Log.v(TAG, "VIDEO_OUTRO END.")
                        playListFragment.nextVideo()
                    }
                }
            }
            super.onPlayerStateChanged(playWhenReady, playbackState)
        }
    }

    fun moveNoteView(data: NoteCanvasData?, sJson: NoteJson) {
        setPlayerPosition()
        val intent = Intent(this, VideoNoteActivity::class.java)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, mVideoViewModel.videoId.value)
        intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, mVideoViewModel.seriesId.value)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_URL, mVideoViewModel.data.value?.videoURL)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_POSITION, mPlayerPosition)
        intent.putExtra(Constants.EXTRA_KEY_NOTE_DATA, data)
        intent.putExtra(Constants.EXTRA_KEY_NOTE_JSON, sJson)
        intent.putExtra(Constants.EXTRA_KEY_DATA, mVideoViewModel.data.value)
        requestActivity.launch(intent)
    }

    private val requestActivity: ActivityResultLauncher<Intent> = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult ->
        if (activityResult.resultCode == Activity.RESULT_OK) {
            noteFragment.backNote(activityResult.data?.getSerializableExtra(Constants.EXTRA_KEY_NOTE_JSON) as NoteJson)
            activityResult.data?.getLongExtra(Constants.EXTRA_KEY_VIDEO_POSITION, 0)?.let {
                mPlayerPosition = it
            }
            mPlayer?.let {
                if (mPlayerPosition == -1L) pausePlayer() else it.seekTo(mPlayerPosition)
            }
        }
    }
    // 관련 시리즈
    private val requestRelationActivity: ActivityResultLauncher<Intent> = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult ->
        when(activityResult.resultCode) {
            RESULT_OK -> {
                if (isFullScreen) setPlayerFullScreen()
                mVideoViewModel.apply {
                    mVideoViewModel.playListOffset.value = Constants.OFFSET_DEFAULT_INT
                    playListFragment.initIsNext()
                    activityResult.data?.let {
                        //bottom
                        videoId.value = it.getStringExtra(Constants.EXTRA_KEY_VIDEO_ID)
                        seriesId.value = it.getStringExtra(Constants.EXTRA_KEY_SERIES_ID)
                        playListNowPosition.value = it.getIntExtra(Constants.EXTRA_KEY_POSITION, 0)
                        playListType.value = it.getIntExtra(Constants.EXTRA_KEY_QUERY, 0)
                        val bool = it.getBooleanExtra(Constants.EXTRA_KEY_IS_AUTO, false)
                        loadPlayList()
                        bottomPosition.value = it.getLongExtra(Constants.EXTRA_KEY_VIDEO_POSITION, 0)
                        bottomTitle.value = it.getStringExtra(Constants.EXTRA_KEY_VIDEO_TITLE)
                        bottomTeacherName.value = it.getStringExtra(Constants.EXTRA_KEY_TEACHER_NAME)
                        bottomURL.value = it.getStringExtra(Constants.EXTRA_KEY_VIDEO_URL)
                        bottomVideoId.value = it.getStringExtra(Constants.EXTRA_KEY_BOTTOM_VIDEO_ID)
                        bottomSeriesId.value = it.getStringExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID)

                        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID)) {
                            mVideoViewModel.bottomSubjectId.value = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID, 0).let { id ->
                                if (id == 0) null else id
                            }
                        }
                        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_GRADE)) {
                            mVideoViewModel.bottomGrade.value = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_GRADE)
                        }
                        if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD)) {
                            bottomKeyword.value = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD)
                        }

                        bottomSorting.value = it.getIntExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, 0)
                        bottomQueryType.value = it.getIntExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE, 0)
                        bottomNowPosition.value = it.getIntExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION, 0)

                        Log.v(TAG, "return bottomSeriesId => ${bottomSeriesId.value}")
                        Log.v(TAG, "return bottomSorting => ${bottomSorting.value}")
                        Log.v(TAG, "return bottomQueryType => ${bottomQueryType.value}")
                        Log.v(TAG, "return bottomNowPosition => ${bottomNowPosition.value}")
                        Log.e(TAG, "Result Code is not find => ${bottomTitle.value} , ${bottomVideoId.value}")
                    }
                }
                backToBottomVideo()
            }
            Constants.RELATION_RESULT_CODE -> {
                activityResult.data?.getLongExtra(Constants.EXTRA_KEY_VIDEO_POSITION, 0)?.let {
                    mPlayerPosition = it
                }
                mPlayer?.let {
                    if (mPlayerPosition == -1L) pausePlayer() else it.seekTo(mPlayerPosition)
                }
            }
            else -> Log.e(TAG, "Result Code is not find => ${activityResult.resultCode}")
        }
    }

    private val requestSearchActivity: ActivityResultLauncher<Intent> = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { activityResult ->
        when(activityResult.resultCode) {
            RESULT_OK -> {
                mVideoViewModel.playListOffset.value = Constants.OFFSET_DEFAULT_INT
                playListFragment.initIsNext()
                if (isFullScreen) setPlayerFullScreen()
                activityResult.data?.let { intent ->
                    // Auto Play = true
                    if (intent.hasExtra(Constants.EXTRA_KEY_TYPE)) {
                        mVideoViewModel.playListType.value = intent.getIntExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_SERIES)
                    } else {
                        mVideoViewModel.playListType.value = Constants.QUERY_TYPE_SERIES
                    }
                    // Default
                    if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_ID)) {
                        mVideoViewModel.videoId.value = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_ID)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_SERIES_ID)) {
                        mVideoViewModel.seriesId.value = intent.getStringExtra(Constants.EXTRA_KEY_SERIES_ID)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_GRADE)) {
                        mVideoViewModel.grade.value = intent.getStringExtra(Constants.EXTRA_KEY_GRADE)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_SUBJECT_ID)) {
                        intent.getIntExtra(Constants.EXTRA_KEY_SUBJECT_ID, 0).let { id ->
                            Log.v(TAG, "SubjectId => $id")
                            mVideoViewModel.subjectId.value = if (id == 0) null else id
                        }
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_KEYWORD)) {
                        mVideoViewModel.keyword.value = intent.getStringExtra(Constants.EXTRA_KEY_KEYWORD)
                        mVideoViewModel.hashTag.value = mVideoViewModel.keyword.value
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_SORTING)) {
                        mVideoViewModel.sorting.value = intent.getIntExtra(Constants.EXTRA_KEY_SORTING, Constants.CONTENT_RESPONSE_VALUE_LATEST)
                    } else {
                        mVideoViewModel.sorting.value = Constants.CONTENT_RESPONSE_VALUE_LATEST
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_NOW_POSITION)) {
                        intent.getIntExtra(Constants.EXTRA_KEY_NOW_POSITION, 0).let { id ->
                            Log.v(TAG, "NowPosition => $id")
                            mVideoViewModel.playListNowPosition.value = if (mVideoViewModel.sorting.value == 4 && mVideoViewModel.playListType.value == Constants.QUERY_TYPE_RECENT_VIDEO) 0 else id
                            Handler(Looper.getMainLooper()).postDelayed({
                                if (Preferences.token.isNotEmpty()) {
                                    mVideoViewModel.loadPlayList()
                                }
                            }, 300L)
                        }
                    } else {
                        mVideoViewModel.getNowPosition()
                    }
                    // Bottom Video
                    if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_URL)) {
                        mVideoViewModel.bottomURL.value = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_URL)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_TITLE)) {
                        mVideoViewModel.bottomTitle.value = intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_TITLE)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_TEACHER_NAME)) {
                        mVideoViewModel.bottomTeacherName.value = intent.getStringExtra(Constants.EXTRA_KEY_TEACHER_NAME)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE)) {
                        mVideoViewModel.bottomQueryType.value = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE, 0)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_VIDEO_ID)) {
                        mVideoViewModel.bottomVideoId.value = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_VIDEO_ID)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID)) {
                        mVideoViewModel.bottomSubjectId.value = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID, 0).let {
                            if (it == 0) null else it
                        }
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_GRADE)) {
                        mVideoViewModel.bottomGrade.value = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_GRADE)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_SORTING)) {
                        val s = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, Constants.CONTENT_RESPONSE_VALUE_LATEST)
                        Log.v(TAG, "search return bottom sorting => $s")
                        mVideoViewModel.bottomSorting.value = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, Constants.CONTENT_RESPONSE_VALUE_LATEST)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID)) {
                        mVideoViewModel.bottomSeriesId.value = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD)) {
                        mVideoViewModel.bottomKeyword.value = intent.getStringExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD)
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_POSITION)) {
                        mVideoViewModel.bottomPosition.value = intent.getLongExtra(Constants.EXTRA_KEY_VIDEO_POSITION, 0)
                        Log.e(TAG,"bottomPosition.value => ${mVideoViewModel.bottomPosition.value}")
                    }
                    if (intent.hasExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION)) {
                        mVideoViewModel.bottomNowPosition.value = intent.getIntExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION, 0)
                    }
                }
                backToBottomVideo()
            }
            Constants.SEARCH_RESULT_CODE -> {
                activityResult.data?.let { intent ->
                    if (isFullScreen) setPlayerFullScreen()
                    if (intent.hasExtra(Constants.EXTRA_KEY_VIDEO_URL)) {
                        noteFragment.noteInvalidate()
                    }
                    intent.getLongExtra(Constants.EXTRA_KEY_VIDEO_POSITION, 0)?.let {
                        mPlayerPosition = it
                    }
                    mPlayer?.let {
                        if (mPlayerPosition == -1L) pausePlayer() else it.seekTo(mPlayerPosition)
                    }
                }
            }
            else -> Log.e(TAG, "Result Code is not find => ${activityResult.resultCode}")
        }
    }


    fun setSearchResultViewInfo() {
        setPlayerPosition()
        mVideoViewModel.data.value?.apply {
            mHashTagRVAdapter.addVideoInfo(
                mVideoViewModel.videoId.value,
                videoURL,
                mPlayerPosition,
                title,
                teacherName,
                seriesId
            )
        }
    }

    fun moveSearchResultView(intent: Intent) {
        requestSearchActivity.launch(intent)
    }

    private fun showLoginAlert() {
        alert(message = resources.getString(R.string.content_text_would_you_like_to_login)) {
            yesButton {
                startActivity(intentFor<LoginActivity>().singleTop())
            }
            noButton { dialog -> dialog.dismiss()
            }
        }.show()
    }

    private fun showRatingDialog() {
        if (Preferences.token.isEmpty()) {
            showLoginAlert()
        } else {
            val builder = AlertDialog.Builder(this)
            val bindingView = DataBindingUtil.inflate<DialogVideoRatingBinding>(
                LayoutInflater.from(this),
                R.layout.dialog_video_rating,
                null,
                false
            )
            builder.setView(bindingView.root)
            ratingDialog = builder.create().apply {
                window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
                setCancelable(false)
                show()
            }

            bindingView.apply {
                // 창 닫기
                btnDialogClose.setOnClickListener { ratingDialog.dismiss() }

                // 현재 평점 카운트
                tvRatingCount.text = getString(
                    R.string.content_text_rating_count2,
                    mVideoViewModel.data.value?.ratingNum
                )

                tvRating.text = getString(R.string.content_text_rating_value, mVideoViewModel.userRating.value ?: "0.0")

                // 현재 평점
                rbRating.rating = (mVideoViewModel.userRating.value ?: "0.0").toFloat()

                // 평점 변경 이벤트
                rbRating.setOnRatingBarChangeListener { _, rating, _ ->
                    bindingView.tvRating.text = getString(
                        R.string.content_text_rating_value,
                        rating.toString()
                    )
                }

                // 적용
                btnApply.setOnClickListener{
                    mVideoViewModel.setUserRating(rbRating.rating.toInt())
                    Handler(Looper.getMainLooper()).postDelayed({
                        mVideoViewModel.load()
                        ratingDialog.dismiss()
                    }, 300L)
                }

            }
        }
    }

    private fun showShareDialog() {
        if (Preferences.token.isEmpty()) {
            showLoginAlert()
        } else {
            val builder = AlertDialog.Builder(this)
            val bindingView = DataBindingUtil.inflate<DialogVideoShareBinding>(
                LayoutInflater.from(this),
                R.layout.dialog_video_share,
                null,
                false
            )
            builder.setView(bindingView.root)
            shareDialog = builder.create().apply {
                window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
                setCancelable(false)
                show()
            }

            bindingView.apply {
                // 창 닫기
                btnDialogClose.setOnClickListener { shareDialog.dismiss() }

                // 페이스북 공유
                btnShareFacebook.setOnClickListener {
                    checkNumberShares(Constants.CONTENT_SHARE_SNS_TYPE_FACEBOOK)
//                    getShareURL(Constants.CONTENT_SHARE_SNS_TYPE_FACEBOOK)
                    shareDialog.dismiss()
                }

                // 카카오톡 공유
                btnShareKakaotalk.setOnClickListener {
//                    getShareURL(Constants.CONTENT_SHARE_SNS_TYPE_KAKAO)
                    checkNumberShares(Constants.CONTENT_SHARE_SNS_TYPE_KAKAO)
                    shareDialog.dismiss()
                }
            }

        }
    }

    private fun checkNumberShares(type: String?) {
        Log.d(TAG, "checkNumberShare Type => $type")
        Constants.apply {
            RetrofitClient.getService().getShareCount(Preferences.token, REQUEST_KEY_FOR_TODAY_VALUE, REQUEST_KEY_FIELD_VALUE, REQUEST_KEY_SHARE_VALUE).enqueue(object : Callback<ShareCount> {
                override fun onFailure(call: Call<ShareCount>, t: Throwable) {
                    Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(call: Call<ShareCount>, response: Response<ShareCount>) {
                    Log.d(TAG, "checkNumberShares onResponse => $response")
                    if (response.isSuccessful) {
                        response.body()?.apply {
                            Log.d(TAG,"checkNumberShares data => $this")
                            if (this.countFiltered < 5) getShareURL(type) else toast(getString(R.string.content_text_toast_limit_number_times_day))
                        }
                    }
                }
            })
        }
    }

    private fun getShareURL(shareType: String?) {
        mVideoViewModel.videoId.value?.let {
            RetrofitClient.getService().getShareURL(it).enqueue(object : Callback<Share> {
                override fun onFailure(call: Call<Share>, t: Throwable) {
                    Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(call: Call<Share>, response: Response<Share>) {
                    if (response.isSuccessful) {
                        Log.d(TAG, "Share Url onResponse => $response")
                        response.body()?.apply {
                            if (data != null) {
                                if (shareType == Constants.CONTENT_SHARE_SNS_TYPE_FACEBOOK) shareFacebook(data.shareUrl!!) else shareKakao(data.shareUrl!!)
                            } else Log.v(TAG, "shareUrl Data is null")
                        }
                    } else Log.d(
                        TAG,
                        "Failed API code : ${response.code()}\n message : ${response.message()}"
                    )
                }
            })
        }
    }

    private fun updateShareCount(type: String) {
        Log.d(TAG,"updateShareCount In: $type")

        Constants.apply {
            val socialType: String = when(type) {
                CONTENT_SHARE_SNS_TYPE_KAKAO    -> CONTENT_SHARE_SNS_TYPE_KK
                CONTENT_SHARE_SNS_TYPE_FACEBOOK -> CONTENT_SHARE_SNS_TYPE_FB
                else -> CONTENT_SHARE_SNS_TYPE_KK
            }
            Log.v(TAG, "socialType => $socialType")
            mVideoViewModel.videoId.value?.let {
                RetrofitClient.getService().updateShareCount(Preferences.token, it, REQUEST_KEY_SHARE_VALUE, socialType).enqueue(object : Callback<ResponseBody> {
                    override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                        Log.d(TAG, " updateShareCount Failed API call with call : $call\nexception : $t")
                    }

                    override fun onResponse(
                        call: Call<ResponseBody>,
                        response: Response<ResponseBody>
                    ) {
                        if (response.isSuccessful || response.code() == 201) {
                            response.body().apply {
                                Log.i(TAG,"updateShareCount Response Body: ${this?.string()}")
                            }
                        } else {
                            Log.d(TAG, "updateShareCount Failed API code : ${response.code()}\n message : ${response.message()}")
                        }
                    }
                })
            }
        }

    }

    // 페이스북 공유
    private fun shareFacebook(url: String) {
        callbackManager = CallbackManager.Factory.create()
        val shareDialog = ShareDialog(this)

        if (ShareDialog.canShow(ShareLinkContent::class.java)) {
            mVideoViewModel.data.value?.let { item ->
                val contentTitle = item.title
                val contentImageUrl = "${Constants.FILE_DOMAIN}/${item.thumbnail}"
                val contentDescription = resources.getString(R.string.content_description_share)
                Log.d(TAG, "contentTitle => $contentTitle")
                Log.d(TAG, "contentDescription => $contentDescription")
                Log.d(TAG, "contentImageUrl => $contentImageUrl")
                Log.d(TAG, "contentUrl => $url")

                val linkContent = ShareLinkContent.Builder()
                    .setContentTitle(contentTitle)
                    .setContentDescription(contentDescription)
                    .setQuote(contentDescription)
                    .setImageUrl(Uri.parse(contentImageUrl))
                    .setContentUrl(Uri.parse(url))
                    .build()

                shareDialog.show(linkContent)
                shareDialog.registerCallback(callbackManager, object : FacebookCallback<Sharer.Result> {
                    override fun onSuccess(result: Sharer.Result?) {
                        Log.v(TAG,"FaceBook 공유 성공: $result")
                        updateShareCount(Constants.CONTENT_SHARE_SNS_TYPE_FACEBOOK)
                    }

                    override fun onCancel() {
                        Log.v(TAG,"FaceBook 공유 취소")
                    }

                    override fun onError(error: FacebookException?) {
                        Log.e(TAG,"FaceBook 공유 실패: $error")
                    }
                })
            }
        }
    }

    // 카카오톡 공유
    private fun shareKakao(url: String) {
        mVideoViewModel.data.value?.let { item ->
            Log.e(TAG, "Data item is $item")
            val contentTitle = item.title
            val contentDescription = resources.getString(R.string.content_description_share)
            val contentImageUrl = "${Constants.FILE_DOMAIN}/${item.thumbnail}"
            Log.e(TAG,"contentImageUrl => $contentImageUrl")

            val defaultFeed = FeedTemplate(
                content = Content(
                    title = contentTitle!!,
                    description = contentDescription,
                    imageUrl = contentImageUrl,
                    imageWidth = 640,
                    imageHeight = 360,
                    link = Link(
                        webUrl = url,
                        mobileWebUrl = url
                    )
                ),
                social = null,
                buttons = listOf(
                    Button(
                        getString(R.string.content_text_view_from_the_web),
                        Link(
                            webUrl = url,
                            mobileWebUrl = url
                        )
                    )
                )
            )

            // 피드 메시지 보내기
            LinkClient.instance.defaultTemplate(this, defaultFeed) { linkResult, error ->
                if (error != null) {
                    Log.e(TAG, "카카오링크 보내기 실패", error)
                    if (error.message == getString(R.string.content_text_error_msg_kakaotalk_not_installed)) toast(R.string.content_text_toast_plz_kakaotalk_installed)
                }
                else if (linkResult != null) {
                    Log.d(TAG, "카카오링크 보내기 성공 ${linkResult.intent}")
                    startActivity(linkResult.intent)

                    updateShareCount(Constants.CONTENT_SHARE_SNS_TYPE_KAKAO)

                    // 카카오링크 보내기에 성공했지만 아래 경고 메시지가 존재할 경우 일부 컨텐츠가 정상 동작하지 않을 수 있습니다.
                    Log.w(TAG, "Warning Msg: ${linkResult.warningMsg}")
                    Log.w(TAG, "Argument Msg: ${linkResult.argumentMsg}")
                }
            }

        }


    }

    private fun moveSeriesActivity(){
        val intent = Intent(this, RelationSeriesActivity::class.java)
        setPlayerPosition()
        intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, mVideoViewModel.seriesId.value)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_POSITION, mPlayerPosition)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE, mVideoViewModel.playListType.value)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_VIDEO_ID, mVideoViewModel.videoId.value)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID, mVideoViewModel.subjectId.value)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_GRADE, mVideoViewModel.grade.value)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, mVideoViewModel.sorting.value)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD, mVideoViewModel.keyword.value)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID, mVideoViewModel.seriesId.value)
        intent.putExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION, mVideoViewModel.playListNowPosition.value)
        intent.putExtra(Constants.EXTRA_KEY_SORTING, mVideoViewModel.sorting.value)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_URL, mVideoViewModel.data.value?.videoURL)
        intent.putExtra(Constants.EXTRA_KEY_VIDEO_TITLE, mVideoViewModel.data.value?.title)
        intent.putExtra(Constants.EXTRA_KEY_TEACHER_NAME, mVideoViewModel.data.value?.teacherName)

        Log.d(
            "넘기기전 값부터 확인",
            " ${mVideoViewModel.playListType.value} ,${mVideoViewModel.playListNowPosition.value}"
        )

        requestRelationActivity.launch(intent)
    }

    fun showLoginToast() {
        toast("로그인 후 이용해주세요.")
        finish()
    }

    private fun showTicketToast() {
        toast("이용권을 구매해주세요.")
        finish()
    }

    private fun showToast(msg: String) {
        toast(msg)
    }

    private fun setPlayerPosition() {
        mPlayer?.let {
            Log.d(TAG, "currentPosition : ${it.currentPosition}")
            Log.d(TAG, "contentPosition : ${it.contentPosition}")
        }
        mPlayer?.currentPosition?.let {
            mPlayerPosition = if (mVideoViewModel.videoMode.value == Constants.VIDEO_OUTRO || mPlayer?.playbackState == Player.STATE_ENDED) { -1L } else { it }
        }
    }

    private fun backToBottomVideo(){
        binding.ivThumbnail.setOnClickListener {
            isBottom = true
            mVideoViewModel.apply {
                hashTag.value = null
                playListOffset.value = Constants.OFFSET_DEFAULT_INT
                playListFragment.initIsNext()

                playListType.value = bottomQueryType.value
                videoId.value = bottomVideoId.value
                seriesId.value = bottomSeriesId.value
                subjectId.value = bottomSubjectId.value
                grade.value = bottomGrade.value
                sorting.value = bottomSorting.value
                keyword.value = bottomKeyword.value

                playListNowPosition.value = bottomNowPosition.value

                hashTag.value = keyword.value

                Log.v(TAG, "bottom playListType => ${playListType.value}")
                Log.v(TAG, "bottom videoId => ${videoId.value}")
                Log.v(TAG, "bottom seriesId => ${seriesId.value}")
                Log.v(TAG, "bottom subjectId => ${subjectId.value ?: 123}")
                Log.v(TAG, "bottom grade => ${grade.value ?: 123}")
                Log.v(TAG, "bottom sorting => ${sorting.value}")
                Log.v(TAG, "bottom keyword => ${keyword.value}")
                Log.v(TAG, "bottom playListNowPosition => ${playListNowPosition.value}")

                loadPlayList()

                Log.d("videoId.value", "videoId.value => ${videoId.value} : ${bottomSeriesId.value}")
                bottomPosition.value?.let { mPlayerBottomPosition = it }
                bottomVideoId.value = null
                bottomURL.value = null
                bottomTeacherName.value = null
                bottomTitle.value = null
                bottomPosition.value = null
                bottomSeriesId.value = null
                bottomSubjectId.value = null
                bottomSorting.value = null
                bottomGrade.value = null
                bottomKeyword.value = null
                bottomQueryType.value = 0
                bottomNowPosition.value = 0

                Log.v(TAG, "bottom mPlayerBottomPosition => $mPlayerBottomPosition")
            }
        }
        binding.icClose.setOnClickListener {
            mVideoViewModel.apply {
                bottomVideoId.value = null
                bottomURL.value = null
                bottomTeacherName.value = null
                bottomTitle.value = null
                bottomPosition.value = null
                bottomSeriesId.value = null
                bottomSubjectId.value = null
                bottomSorting.value = null
                bottomGrade.value = null
                bottomKeyword.value = null
                bottomQueryType.value = 0
                bottomNowPosition.value = 0
            }
        }
    }

    private fun hideSystemUI() {
        // Enables regular immersive mode.
        // For "lean back" mode, remove SYSTEM_UI_FLAG_IMMERSIVE.
        // Or for "sticky immersive," replace it with SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_IMMERSIVE
                // Set the content to appear under the system bars so that the
                // content doesn't resize when the system bars hide and show.
                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                // Hide the nav bar and status bar
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_FULLSCREEN)
    }

    // Shows the system bars by removing all the flags
    // except for the ones that make the content appear under the system bars.
    private fun showSystemUI() {
        window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
    }

    companion object {
        private val TAG = VideoActivity::class.java.simpleName
        private const val TRIM_ON_RESET = true // 할당 자 재설정시 메모리 해제 여부. 할당자가 여러 플레이어 인스턴스에서 재사용되지 않는 한 참이어야 합니다.
        private const val INDIVIDUAL_ALLOCATION_SIZE = 16 // 각 Allocation 의 길이
        private const val TARGET_BUFFER_BYTES = -1 // 대상 버퍼 크기 : 바이트 단위
        private const val PRIORITIZE_TIME_OVER_SIZE_THRESHOLDS = true // 부하 제어가 버퍼 크기 제약보다 버퍼 시간 제약을 우선시하는지 여부
        private const val MIN_BUFFER_DURATION = 2000 // 플레이어가 항상 버퍼링을 시도하는 미디어의 최소 기간 : 2초
        private const val MAX_BUFFER_DURATION = 5000 // 플레이어가 버퍼링을 시도하는 미디어의 최대 기간 : 5초
        private const val PLAYBACK_START_BUFFER_DURATION  = 1500 // 탐색과 같은 사용자 작업 후 재생을 시작하거나 다시 시작하기 위해 버퍼링해야하는 미디어의 지속 시간 : 1.5초
        private const val PLAYBACK_RESUME_BUFFER_DURATION = 2000 // 리 버퍼 후 재생을 재개하기 위해 버퍼링해야하는 미디어의 기본 기간 : 2초
        private const val RANDOM_MINIMUM_VALUE = 0
        private const val RANDOM_MAXIMUM_VALUE = 1
    }

}