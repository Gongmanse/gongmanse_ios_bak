@file:Suppress("DEPRECATION")
package com.gongmanse.app.utils

import android.annotation.SuppressLint
import com.gongmanse.app.R
import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.text.Html
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.TextView
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import androidx.constraintlayout.widget.Group
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.activities.MainActivity
import com.gongmanse.app.api.video.VideoService
import com.gongmanse.app.fragments.HomeFragment
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.extractor.DefaultExtractorsFactory
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.source.MergingMediaSource
import com.google.android.exoplayer2.source.SingleSampleMediaSource
import com.google.android.exoplayer2.source.TrackGroupArray
import com.google.android.exoplayer2.text.TextOutput
import com.google.android.exoplayer2.trackselection.*
import com.google.android.exoplayer2.ui.AspectRatioFrameLayout
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.ui.TimeBar
import com.google.android.exoplayer2.upstream.DefaultAllocator
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.MimeTypes
import com.google.android.exoplayer2.util.Util
import kotlinx.android.synthetic.main.custom_video_timebar.view.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.jetbrains.anko.sdk27.coroutines.onClick
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap


class VideoPlayerRecyclerView : RecyclerView {
    constructor(@NonNull context: Context) : this(context, null)
    constructor(@NonNull context: Context, @Nullable attributeSet: AttributeSet?) : this(context, attributeSet, 0)
    constructor(@NonNull context: Context, @Nullable attributeSet: AttributeSet?, defStyleAttr: Int) : super(context, attributeSet, defStyleAttr) {
        attributeSet?.let {
            val typedArray = context.obtainStyledAttributes(it, R.styleable.video_player_recycler_view)
            val isBest = typedArray.getBoolean(R.styleable.video_player_recycler_view_is_best, false)
            typedArray.recycle()

            isBestTab = isBest//use guest key. & has 2 headers.
            startIdx = if (isBestTab) 2 else 0
        }
        initListener()
    }
    private enum class VolumeState {
        ON, OFF
    }
    private val client = VideoService.client

    companion object {
        @SuppressLint("StaticFieldLeak")
        private var mInstance: VideoPlayerRecyclerView? = null
        private const val TRIM_ON_RESET = true // 할당 자 재설정시 메모리 해제 여부. 할당자가 여러 플레이어 인스턴스에서 재사용되지 않는 한 참이어야 합니다.
        private const val INDIVIDUAL_ALLOCATION_SIZE = 16 // 각 Allocation 의 길이
        private const val TARGET_BUFFER_BYTES = -1 // 대상 버퍼 크기 : 바이트 단위
        private const val PRIORITIZE_TIME_OVER_SIZE_THRESHOLDS = true // 부하 제어가 버퍼 크기 제약보다 버퍼 시간 제약을 우선시하는지 여부
        private const val MIN_BUFFER_DURATION = 2000 // 플레이어가 항상 버퍼링을 시도하는 미디어의 최소 기간 : 2초
        private const val MAX_BUFFER_DURATION = 5000 // 플레이어가 버퍼링을 시도하는 미디어의 최대 기간 : 5초
        private const val PLAYBACK_START_BUFFER_DURATION  = 1500 // 탐색과 같은 사용자 작업 후 재생을 시작하거나 다시 시작하기 위해 버퍼링해야하는 미디어의 지속 시간 : 1.5초
        private const val PLAYBACK_RESUME_BUFFER_DURATION = 2000 // 리 버퍼 후 재생을 재개하기 위해 버퍼링해야하는 미디어의 기본 기간 : 2초
        var videoSeekTime:MutableMap<String, Long> = HashMap()
        private var hasSeekTime = false
        var isGuest = true
        fun stopVideo() {
            mInstance?.let {
                if (!it.isBestTab)
                    it.resetVideoView()
            }
        }
    }

    // ui
    private var viewHolderParent: View? = null
    private var frameLayout: FrameLayout? = null
    private var subtitleView: TextView? = null
    private var btnGroup: Group? = null
    private var btnMute: ImageButton? = null
    private var btnCaption: ImageButton? = null
    private var videoSurfaceView: PlayerView? = null
    private var videoPlayer: SimpleExoPlayer? = null

    // vars
    private var playPosition = -1
    private var playVideoId = ""
    private var isVideoViewAdded = false     // videoView 는 리스트에서 단일객체로 존재하도록..
    private var scrollToBot = true
    private var volumeState = VolumeState.OFF
    var videoIds: MutableList<String> = mutableListOf()
    private var isBestTab = false
    private var startIdx = 2
    var isPiPOn = false
    var isAutoPlayOff = false

    private fun initListener() {
        addOnScrollListener(object : OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                if (newState == SCROLL_STATE_IDLE) {// 스크롤이 멈춘 이후에 재생 관리...
                    if (!isBestTab && isGuest) {
                        GBLog.e("", "isGuest : $isGuest")
                        return
                    }

                    if (isPiPOn) {
                        GBLog.e("", "isPipOn : $isPiPOn")
                        return
                    }

                    if (isAutoPlayOff) {// 홈 > 국영수, 과학, 사회, 기타 탭에서 시리스&노트 보기 상태인 경우 자동재생 동작하지 않도록
                        GBLog.e("", "isAutoPlayOff : $isAutoPlayOff")
                        return
                    }

                    if (!recyclerView.canScrollVertically(1)) {// when the end of the list has been reached.
                        playVideo(true)
                    } else if (!recyclerView.canScrollVertically(-1)) {// when the top of the list has been reached.
                        if (isBestTab) {
                            GBLog.e("", "scroll to Top. stop playing video.")
                            resetVideoView()
                        } else {
                            playVideo(false)
                        }
                    } else {
                        playVideo(false)
                    }
                }
            }

            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)
                scrollToBot = dy > 0
            }
        })

        addOnChildAttachStateChangeListener(object : OnChildAttachStateChangeListener {
            override fun onChildViewAttachedToWindow(view: View) {}
            override fun onChildViewDetachedFromWindow(view: View) {
                if (viewHolderParent != null && viewHolderParent!! == view) {
                    resetVideoView()
                }
            }
        })

        GBLog.i("TAG", "init done")
    }

    fun checkSmallItemList() {
        // 스크롤이 불가한 적은 아이템인 경우 처리
        val firstCompletePosition = (layoutManager as LinearLayoutManager?)!!.findFirstCompletelyVisibleItemPosition()
        val lastCompletePosition = (layoutManager as LinearLayoutManager?)!!.findLastCompletelyVisibleItemPosition()
        val startPosition = (layoutManager as LinearLayoutManager?)!!.findFirstVisibleItemPosition()
        val endPosition = (layoutManager as LinearLayoutManager?)!!.findLastVisibleItemPosition()
        GBLog.e("","================================" +
                "\nfirstVisiblePosition : $startPosition\nfirstCompletePosition : $firstCompletePosition \nlastCompletePosition : $lastCompletePosition\nlastVisiblePosition : $endPosition")

        if (startPosition < 0 || endPosition < 0) {
            GBLog.e("", "something wrong")
            return
        }

        if (startPosition == firstCompletePosition && endPosition == lastCompletePosition) {
            Handler(Looper.getMainLooper()).postDelayed( {
                GBLog.i("", "delayed play video")
                playVideo(false)
            }, 500)
        }
    }

    private fun initPlayer() {
        val trackSelector = DefaultTrackSelector()
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

        // Create the player
        val renderersFactory = DefaultRenderersFactory(context)
        videoPlayer = ExoPlayerFactory.newSimpleInstance(
            context,
            renderersFactory,
            trackSelector,
            loadControl
        ).apply {
            addTextOutput(onTextOutputListener) // 출력을 등록하여 텍스트 이벤트를 수신
        }

        videoPlayer!!.addListener(object : Player.EventListener {
            override fun onTimelineChanged(timeline: Timeline, manifest: Any?, reason: Int) {}
            override fun onTracksChanged(
                trackGroups: TrackGroupArray,
                trackSelections: TrackSelectionArray
            ) {
            }

            override fun onLoadingChanged(isLoading: Boolean) {}
            override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {

                when (playbackState) {
                    Player.STATE_BUFFERING -> {
                        GBLog.e("TAG", "onPlayerStateChanged: Buffering video.")
                    }
                    Player.STATE_ENDED -> {
                        GBLog.d("TAG", "onPlayerStateChanged: Video ended.")
//                        videoSeekTime[playVideoId] = 0
                        videoSurfaceView?.visibility = INVISIBLE
                        btnGroup?.visibility = INVISIBLE
                        videoPlayer?.seekTo(0)
                        subtitleView?.text = ""

                        val currPos = playPosition - startIdx
                        GBLog.d("TAG", "Video ended. : currPos : $currPos, videoSize : ${videoIds.size}")
                        if ((playPosition - startIdx) < (videoIds.size - 1)) {//마지막 아이템 이전까지만 자동 스크롤 지원
                            scrollToItemTopPosition(playPosition + 1)
                        } else {
                            GBLog.i("", "lastItem end")
                            resetVideoView()
                        }
                    }
                    Player.STATE_IDLE -> {
                    }
                    Player.STATE_READY -> {
                        GBLog.e("TAG", "onPlayerStateChanged: Ready to play. isVideoViewAdded : $isVideoViewAdded, playWhenReady : $playWhenReady")
                        if (playWhenReady) {
                            (context as Activity).window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            videoSurfaceView?.visibility = VISIBLE
                            videoSurfaceView?.showController()
                            videoSurfaceView?.requestFocus()
                            btnGroup?.visibility = VISIBLE
                        }
                        else
                            (context as Activity).window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

                        if (hasSeekTime) {
                            val seekTime = videoSeekTime[playVideoId]!!
                            GBLog.e("TAG", "do seekTo : $seekTime")
                            videoPlayer?.seekTo(seekTime)
                            videoPlayer?.playWhenReady = true
                            hasSeekTime = false
                        }
                    }
                    else -> {
                    }
                }
            }

            override fun onRepeatModeChanged(repeatMode: Int) {}
            override fun onShuffleModeEnabledChanged(shuffleModeEnabled: Boolean) {}
            override fun onPlayerError(error: ExoPlaybackException) {}
            override fun onPositionDiscontinuity(reason: Int) {}
            override fun onPlaybackParametersChanged(playbackParameters: PlaybackParameters) {}
            override fun onSeekProcessed() {}
        })
    }

    private var nextPlayItemPosition = -1
    private var isAutoScroll = false
    private fun scrollToItemTopPosition(pos: Int) {
        playPosition = -1// auto scroll 시 해당 position 아이템이 재생되도록 기존 재생 아이템 정보 초기화.
        isAutoScroll = true
        nextPlayItemPosition = pos

        // 화면에 보여지는 아이템 갯수에 따라서 오토 스크롤 범위 조정
        val lastCompletePosition = (layoutManager as LinearLayoutManager?)!!.findLastCompletelyVisibleItemPosition()
        if (nextPlayItemPosition == lastCompletePosition)
            smoothScrollToPosition(pos + 1)// 해당 뷰가 상단으로 올라오도록 스크롤
        else
            smoothScrollToPosition(pos)// 해당 뷰가 보이는 곳까지 스크롤
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        GBLog.i("TAG", "onAttachedToWindow")
    }

    override fun onDetachedFromWindow() {
        GBLog.i("TAG", "onDetachedFromWindow")
        mInstance = null
        super.onDetachedFromWindow()
    }

    fun playVideo(isEndOfList: Boolean) {
        val targetPosition: Int

        /*
        * startIdx : first visible position.
        * header 포함. 추천탭인 경우 첫번째 아이템 position 은 2.
        * */
        if (!isEndOfList) {
            val firstCompletePosition = (layoutManager as LinearLayoutManager?)!!.findFirstCompletelyVisibleItemPosition()
            val lastCompletePosition = (layoutManager as LinearLayoutManager?)!!.findLastCompletelyVisibleItemPosition()
            var startPosition = (layoutManager as LinearLayoutManager?)!!.findFirstVisibleItemPosition()
            var endPosition = (layoutManager as LinearLayoutManager?)!!.findLastVisibleItemPosition()
            GBLog.d("","================================" +
                    "\nfirstVisiblePosition : $startPosition\nfirstCompletePosition : $firstCompletePosition \nlastCompletePosition : $lastCompletePosition\nlastVisiblePosition : $endPosition")
            GBLog.i("", "startIdx : $startIdx")

            when {
                startPosition < startIdx -> {
                    GBLog.i("TAG", "at Best")
                    when {
                        scrollToBot -> {
                            if (startPosition > 0 && firstCompletePosition > 0) {
                                GBLog.i("TAG", "start first item in Best")
                                targetPosition = startIdx
                            } else {
                                GBLog.e("TAG", "header area visible... do nothing... 재생 중이면 그대로")
                                return
                            }
                        }
                        else -> {
                            if (playPosition > 0) {
                                targetPosition = checkViewSelect(startIdx, startIdx + 1)
                                GBLog.i("TAG", "playPosition : $playPosition... set $targetPosition")
                            } else {
                                if (startPosition > 0 && firstCompletePosition > 0) {
                                    targetPosition = startIdx
                                } else {
                                    GBLog.e("TAG", "header area visible... do nothing... 재생 중이면 그대로")
                                    return
                                }
                            }
                        }
                    }
                }

                else -> {
                    GBLog.i("","first item $startPosition")
                    // something is wrong. return.
                    if (startPosition < 0 || endPosition < 0) { return }

                    // 스크롤 방향에 따라 현재 아이템과 다음 아이템을 구분
                    if (scrollToBot) {
                        endPosition = startPosition + 1// 위에서 두개
                    } else {
                        startPosition = endPosition - 1// 아래서 두개
                    }

                    GBLog.i("", "nextPlayItemPosition : $nextPlayItemPosition")
                    targetPosition =
                        if (isAutoScroll)
                            nextPlayItemPosition
                        else
                            checkViewSelect(startPosition, endPosition)
                }
            }
        } else {// 리스트 마지막 아이템 재생
            targetPosition = adapter!!.itemCount + (startIdx - 1)
        }
        GBLog.d("TAG", "playVideo: target position: $targetPosition")

        // video is already playing so return
        if (targetPosition == playPosition) {
            return
        }


        // remove any old surface views from previously playing videos
        resetVideoView()

        initPlayer()

        setVolumeControl(volumeState)

        // set the position of the list-item that is to be played
        playPosition = targetPosition
        GBLog.v("TAG", "playPosition : $playPosition")

        isAutoScroll = false
        nextPlayItemPosition = -1


        val currentPosition = targetPosition - (layoutManager as LinearLayoutManager?)!!.findFirstVisibleItemPosition()
        GBLog.i("TAG", "child currentPosition : $currentPosition")

        val child = getChildAt(currentPosition) ?: return
        GBLog.v("TAG", "child not null")

        val holder: ViewHolder? = child.tag as? ViewHolder
        if (holder == null) {
            playPosition = -1
            return
        }
        GBLog.v("TAG", "holder not null")


        // init holder
        mInstance = this
        viewHolderParent = holder.itemView
        frameLayout = holder.itemView.findViewById(R.id.fl_video_container)
        videoSurfaceView = holder.itemView.findViewById(R.id.player_view)
        btnGroup = holder.itemView.findViewById(R.id.group_exo_btn)
        btnMute = holder.itemView.findViewById(R.id.exo_mute)
        btnMute!!.onClick {
            if (volumeState == VolumeState.OFF) {
                volumeState = VolumeState.ON
                btnMute!!.setImageResource(R.drawable.ic_small_volume_on)
            } else {
                volumeState = VolumeState.OFF
                btnMute!!.setImageResource(R.drawable.ic_small_volume_off)
            }
            setVolumeControl(volumeState)
        }
        if (volumeState == VolumeState.OFF)
            btnMute!!.setImageResource(R.drawable.ic_small_volume_off)
        else
            btnMute!!.setImageResource(R.drawable.ic_small_volume_on)



        // init & bind player to the view.
        videoSurfaceView!!.apply {
            player = videoPlayer
            useController = true
            controllerHideOnTouch = false
            controllerShowTimeoutMs = 0
            resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
            subtitleView?.visibility = View.GONE // 내장 subtitleView 숨김
            setShutterBackgroundColor(Color.TRANSPARENT) // exo_shutter 투명처리

            exo_progress.addListener(object: TimeBar.OnScrubListener {
                override fun onScrubStart(timeBar: TimeBar, position: Long) {
                    (context as? MainActivity)?.selectedFragment()?.let {
                        GBLog.i("TAG", "current fragment : ${it.javaClass.kotlin}")
                        if (it is HomeFragment) {
                            GBLog.i("TAG", "onScrubStart. block MainActivity-HomeFragment.pager")
                            it.getPager().requestDisallowInterceptTouchEvent(true)
                        }
                    }
                }

                override fun onScrubMove(timeBar: TimeBar, position: Long) { }

                override fun onScrubStop(timeBar: TimeBar, position: Long, canceled: Boolean) {
                    (context as? MainActivity)?.selectedFragment()?.let {
                        GBLog.i("TAG", "current fragment : ${it.javaClass.kotlin}")
                        if (it is HomeFragment) {
                            GBLog.i("TAG", "onScrubStop. release swipe pager")
                            it.getPager().requestDisallowInterceptTouchEvent(false)
                        }
                    }
                }
            })
        }
        videoSurfaceView!!.setOnTouchListener { _, event ->
            if( event.action == MotionEvent.ACTION_UP) {
                holder.itemView.performClick()
            }
            false
        }

        subtitleView = videoSurfaceView!!.findViewById(R.id.tv_subtitle)
        subtitleView!!.text = ""

        btnCaption = holder.itemView.findViewById(R.id.exo_caption)
        btnCaption!!.onClick {
            if (subtitleView!!.visibility == View.VISIBLE) {
                subtitleView!!.visibility = View.GONE
                btnCaption!!.setImageResource(R.drawable.ic_small_caption_off)
            } else {
                subtitleView!!.visibility = View.VISIBLE
                btnCaption!!.setImageResource(R.drawable.ic_small_caption_on)
            }
        }

        playVideoId = videoIds[targetPosition - startIdx]// header count, index start position 확인.
        getVideoData(playVideoId)
    }


    private var tags: MutableList<String> = ArrayList()
    private fun getVideoData(videoId: String) {
        GBLog.d("TAG", "request videoId : $videoId")
        CoroutineScope(Dispatchers.IO).launch {
            if (isBestTab)
                client.getVideoData2(Preferences.token, videoId).let { response ->
                    if (response.isSuccessful) {
                        response.body()?.let { body ->
                            GBLog.d("TAG", "get Best Video response data : ${body.data}")
                            if (body.data != null) {
                                // guest 로 요청 시 videoId 받을 수 없음...
//                                if (playVideoId == body.data.id) {// 현재 위치화 응답 결과 비교
                                    val videoUrl = body.data.videoURL!!
                                    val subtitleUrl = "${Constants.FILE_DOMAIN}/${body.data.subtitle}"
                                    body.data.tags?.split(",")?.let { tags.addAll(it) }
                                    GBLog.i("TAG", "tags : $tags")
                                    CoroutineScope(Dispatchers.Main).launch {
                                        prepareVideo(videoUrl, subtitleUrl)
                                    }
//                                }
                            }
                        }
                    } else {
                        GBLog.e("TAG","${response.errorBody()}")
                    }
                }
            else
                client.getVideoData(Preferences.token, videoId).let { response ->
                    if (response.isSuccessful) {
                        response.body()?.let { body ->
                            GBLog.d("TAG", "get Video response data : ${body.data}")
                            if (body.data != null) {
                                if (playVideoId == body.data.id) {// 현재 위치화 응답 결과 비교
                                    val videoUrl = body.data.videoURL!!
                                    val subtitleUrl = "${Constants.FILE_DOMAIN}/${body.data.subtitle}"
                                    body.data.tags?.split(",")?.let { tags.addAll(it) }
                                    GBLog.i("TAG", "tags : $tags")
                                    CoroutineScope(Dispatchers.Main).launch {
                                        prepareVideo(videoUrl, subtitleUrl)
                                    }

                                }
                            }
                        }
                    } else {
                        GBLog.e("TAG","${response.errorBody()}")
                    }
                }
        }
    }

    private fun prepareVideo(videoUrl: String, subtitleUrl: String) {
        GBLog.d("TAG", "\nvideoUrl : $videoUrl,\n subtitleUrl : $subtitleUrl")
        val subtitleUri = Uri.parse(subtitleUrl)
        val contentMediaSource = ExtractorMediaSource(
            Uri.parse(videoUrl),
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
        videoPlayer?.apply {
            GBLog.i("", "videoPlayer apply")
            prepare(mediaSource, true, false)

            val seekTime = videoSeekTime[playVideoId]
            hasSeekTime = seekTime != null && seekTime > 0
            videoPlayer!!.playWhenReady = !hasSeekTime
        }
    }

    private fun getDefaultDataSourceFactory(): DefaultDataSourceFactory {
        return DefaultDataSourceFactory(context, Util.getUserAgent(context,resources.getString(R.string.app_name)))
    }

    private fun checkViewSelect(first: Int, second: Int): Int {
        return if (first != second) {
            val startPositionVideoHeight: Int = getVisibleVideoSurfaceHeight(first)
            val endPositionVideoHeight: Int = getVisibleVideoSurfaceHeight(second)
            GBLog.d("","firstVisiblePosition : $first, h: $startPositionVideoHeight")
            GBLog.d("","secondVisiblePosition : $second, h : $endPositionVideoHeight")

            if (startPositionVideoHeight > endPositionVideoHeight) first else second
        } else {
            first
        }
    }

    private fun getVisibleVideoSurfaceHeight(checkPosition: Int): Int {
        val at =
            checkPosition - (layoutManager as LinearLayoutManager?)!!.findFirstVisibleItemPosition()

        val location = IntArray(2)

        val child = getChildAt(at) ?: return 0
        child.getLocationInWindow(location)
        var childY = if (location[1] > 0) location[1] else 0

        val nextChild = getChildAt(at + 1) ?: null
        val nextChildY = if (nextChild != null) {
            nextChild.getLocationInWindow(location)
            location[1]
        } else {
            -1
        }

        this.getLocationInWindow(location)
        val thisY = location[1]
        val maxY = this.height + thisY
        if (childY < thisY)
            childY = thisY

        val childVisibleH = if (nextChildY > 0) {
            nextChildY - childY
        } else {
            maxY - childY
        }
        GBLog.d("TAG", "playPosition : $checkPosition, childY : $childY, nextChildY : $nextChildY")

        // 스크롤 방향에 따라 가려지는 playerView 의 비율이 다르기 때문에 각각 계산.
        //
        return if (checkPosition == startIdx || checkPosition == playPosition) {
            if (scrollToBot)
                (childVisibleH * 1.6).toInt()// itemViewHeight 769 기준 상단 37% 가려진 시점
            else
                (childVisibleH * 2.7).toInt()// itemViewHeight 769 기준 하단 63% 가려진 시점
        } else
            childVisibleH
    }

    private fun resetVideoView() {
        (context as Activity).window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        val seekTime = videoPlayer?.currentPosition
        videoPlayer?.playWhenReady = false
        videoPlayer?.release()
        hasSeekTime = false
        seekTime?.let{
            GBLog.v("TAG", "video item click, save play time. $it ms")
            if (it > 0)
                videoSeekTime[playVideoId] = it
        }

        videoSurfaceView?.visibility = INVISIBLE
        btnGroup?.visibility = INVISIBLE
        subtitleView?.text = ""

        playPosition = -1
        viewHolderParent = null
        mInstance = null
    }

    fun pausePlayer() {
        resetVideoView()
    }

    fun releasePlayer() {
        if (videoPlayer != null) {
            videoPlayer!!.playWhenReady = false
            videoPlayer!!.release()
            videoPlayer = null
        }
        viewHolderParent = null
    }

    private fun setVolumeControl(state: VolumeState) {
        volumeState = state
        if (state === VolumeState.OFF) {
            videoPlayer!!.volume = 0f
        } else if (state === VolumeState.ON) {
            videoPlayer!!.volume = 1f
        }
    }


    /*
    * player 내부 자막 뷰 편집하지 않고, 커스텀뷰로 자막 구현
    * */
    private fun addSubTitleInEventView(str: CharSequence) {
        GBLog.v("", "addSubTitleInEventView : $str")
//        val htmlString = Html.fromHtml(str.toString().replace("ffff00", "ffffff"))

        var tagString = str.toString()
        tags.map {
            if (str.toString().contains(it)) {
                tagString = tagString.replace(it, String.format(Locale.KOREA, "<font color=\"#ff8000\">%s</font>", it))
            }
        }
        val htmlString = Html.fromHtml(tagString)

        subtitleView?.text = htmlString
        subtitleView?.textSize = if (Constants.isTablet(context)) 17F else 13F
    }

    private val onTextOutputListener = TextOutput {
        for (c in it) {
            c.text?.let { subtitle ->
                addSubTitleInEventView(subtitle)
            }
        }
    }
}