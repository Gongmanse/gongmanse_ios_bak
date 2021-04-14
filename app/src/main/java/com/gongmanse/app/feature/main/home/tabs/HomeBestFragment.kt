package com.gongmanse.app.feature.main.home.tabs

import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.observe
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.R
import com.gongmanse.app.data.model.Body
import com.gongmanse.app.databinding.FragmentBestBinding
import com.gongmanse.app.feature.main.LiveDataVideo
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.EndlessRVScrollListener
import com.gongmanse.app.utils.Preferences

@Suppress("DEPRECATION")
class HomeBestFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = HomeBestFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentBestBinding
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mRecyclerAdapter: HomeBestAdapter
    private lateinit var viewModel: LiveDataVideo
    private val linearLayoutManager = LinearLayoutManager(context)
    private var mOffset: Int = 0
    private var isLoading = false

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_best, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onRefresh() {
        mOffset = 0
        viewModel.liveDataClear()
        mRecyclerAdapter.clear()
        isLoading = false
        binding.refreshLayout.isRefreshing = false
        prepareData()
    }

    private fun initView() {
        binding.refreshLayout.setOnRefreshListener(this)
        viewModel = ViewModelProvider(this).get(LiveDataVideo::class.java)
        viewModel.currentValue.observe(viewLifecycleOwner) {
            if(isLoading) mRecyclerAdapter.removeLoading()
            mRecyclerAdapter.addItems(it)
            Log.d(TAG,"$it")
            isLoading = false
        }
        setRVLayout()
        prepareData()
    }

    fun scrollToTop() {
        binding.rvVideo.smoothScrollToPosition(0)
    }

    private fun setRVLayout() {
        binding.rvVideo.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            layoutManager = linearLayoutManager
        }
        if (binding.rvVideo.adapter == null) {
            mRecyclerAdapter = HomeBestAdapter()
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
        viewModel.loadVideo(sGrade,mOffset,Constants.DefaultValue.LIMIT_INT)
    }

    private fun prepareData() {
        // 최초 호출
        val bannerData = Body().apply { itemType = Constants.BestValue.BANNER_TYPE }
        val titleData = Body().apply { itemType = Constants.BestValue.TITLE_TYPE }
        mRecyclerAdapter.addItems(listOf(bannerData, titleData))

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
        mOffset = offset
        Log.e(TAG,"loadMoreData offset => $offset")
        if (isLoading) {
            mRecyclerAdapter.addLoading()
        }
        Handler().postDelayed({
            loadVideo()
        }, Constants.Delay.VALUE_OF_ENDLESS)
    }

}
