package com.gongmanse.app.feature.main.home.tabs

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.data.network.home.VideoRepository
import com.gongmanse.app.databinding.FragmentHotBinding
import com.gongmanse.app.feature.main.VideoViewModel
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.EndlessRVScrollListener
import com.gongmanse.app.utils.Preferences


class HomeHotFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = HomeHotFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentHotBinding
    private lateinit var mRecyclerAdapter: HomeSubjectRVAdapter
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var videoViewModel : VideoViewModel
    private lateinit var mVideoViewModelFactory: VideoViewModelFactory
    private val linearLayoutManager = LinearLayoutManager(context)
    private var mOffset: Int = Constants.DefaultValue.OFFSET_INT
    private var isLoading = false

    override fun onRefresh() {
        mOffset = 0
        videoViewModel.liveDataClear()
        mRecyclerAdapter.clear()
        isLoading = false
        binding.refreshLayout.isRefreshing = false
        prepareData()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater,R.layout.fragment_hot, container, false)
        initView()
        prepareData()
        return binding.root
    }

    private fun initView() {
        binding.refreshLayout.setOnRefreshListener(this)
        binding.setVariable(BR.title,Constants.Home.TAB_TITLE_ETC)
        if (::mVideoViewModelFactory.isInitialized.not()) {
            mVideoViewModelFactory = VideoViewModelFactory(VideoRepository())
        }
        if (::videoViewModel.isInitialized.not()) {
            videoViewModel = ViewModelProvider(this, mVideoViewModelFactory).get(VideoViewModel::class.java)
        }
        videoViewModel = ViewModelProvider(this).get(VideoViewModel::class.java)
        videoViewModel.currentValue.observe(viewLifecycleOwner) {
            if(isLoading) mRecyclerAdapter.removeLoading()
            mRecyclerAdapter.addItems(it)
            Log.d(TAG,"$it")
            isLoading = false
        }
        setRVLayout()
    }
    fun scrollToTop(){
        binding.rvVideo.smoothScrollToPosition(0)
    }
    private fun setRVLayout() {
        binding.rvVideo.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            layoutManager = linearLayoutManager
        }
        if (binding.rvVideo.adapter == null) {
            mRecyclerAdapter = HomeSubjectRVAdapter()
            binding.rvVideo.adapter = mRecyclerAdapter
        }
    }

    private fun loadVideo() {
        var sGrade : String? = null
        if(Preferences.grade.isEmpty()){
            Log.d(TAG, "Preferences.grade => ${Preferences.grade}")
        }else {
            sGrade = when (Preferences.grade[0]) {
                '초' -> Constants.GradeType.ELEMENTARY
                '중' -> Constants.GradeType.MIDDLE
                '고' -> Constants.GradeType.HIGH
                else -> null
            }
        }
        videoViewModel.loadHot(sGrade,mOffset,Constants.DefaultValue.LIMIT_INT)
    }
    private fun prepareData() {
        // 최초 호출
        Log.d(TAG, "prepareData...")
        loadVideo()

        // 스크롤 이벤트
        scrollListener = object : EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if (!isLoading && mOffset != totalItemsCount && totalItemsCount >= 20) {
                    isLoading = true
                    loadMoreData(totalItemsCount)
                }
            }
        }

        // 스크롤 이벤트 초기화
        binding.rvVideo.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        Log.d(TAG, "loadMoreData : isLoading => $isLoading")
        if (isLoading) {
            mRecyclerAdapter.addLoading()
        }
        Handler(Looper.getMainLooper()).postDelayed({
            mOffset = offset
            loadVideo()
        }, Constants.Delay.VALUE_OF_ENDLESS)
    }

}