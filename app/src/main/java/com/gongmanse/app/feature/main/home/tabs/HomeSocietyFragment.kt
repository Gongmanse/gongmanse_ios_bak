package com.gongmanse.app.fragments.home

import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.observe
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.feature.main.home.tabs.HomeSubjectRVAdapter
import com.gongmanse.app.databinding.FragmentSubjectBinding
import com.gongmanse.app.feature.main.LiveDataVideo
import com.gongmanse.app.feature.main.home.tabs.HomeKEMFragment
import com.gongmanse.app.feature.main.home.tabs.SelectionSheet
import com.gongmanse.app.feature.main.home.tabs.SelectionSheetSpinner
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.EndlessRVScrollListener
import com.gongmanse.app.utils.listeners.OnBottomSheetListener
import com.gongmanse.app.utils.listeners.OnBottomSheetSpinnerListener


@Suppress("DEPRECATION")
class HomeSocietyFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener, OnBottomSheetListener,
    OnBottomSheetSpinnerListener {

    companion object {
        private val TAG = HomeSocietyFragment::class.java.simpleName
    }

    private lateinit var mRecyclerAdapter: HomeSubjectRVAdapter
    private lateinit var binding: FragmentSubjectBinding
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var bottomSheet: SelectionSheet
    private lateinit var bottomSheetSpinner: SelectionSheetSpinner
    private var page: Int = Constants.OFFSET_DEFAULT_INT                                        // api 페이지
    private var isLoading = false
    private val type = 3
    private var selectView: String = Constants.CONTENT_VALUE_ALL         // 선택한 select 박스
    private var selectOrder: String = Constants.CONTENT_VALUE_AVG        // 선택한 정렬
    private val linearLayoutManager = LinearLayoutManager(context)

    private lateinit var viewModel: LiveDataVideo


    override fun onRefresh() {
        page = 0
        viewModel.liveDataClear()
        mRecyclerAdapter.clear()
        isLoading = false
        binding.refreshLayout.isRefreshing = false
        prepareData()
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_subject, container, false)
        setRVLayout()
        initView()
        return binding.root
    }

    private fun initView() {
        binding.refreshLayout.setOnRefreshListener(this)
        binding.setVariable(BR.title,Constants.HOME_TAB_TITLE_SOCIETY)
        viewModel = ViewModelProvider(this).get(LiveDataVideo::class.java)
        prepareData()
        viewModel.currentValue.observe(viewLifecycleOwner) {
            if(isLoading) mRecyclerAdapter.removeLoading()
            mRecyclerAdapter.addItems(it)
            isLoading = false
        }
        viewModel.totalValue.observe(viewLifecycleOwner){
            binding.tvVideoCount.setVariable(BR.totalNum, it)
        }
        selectionsControl()
    }

    private fun selectionsControl(){
        binding.tvSelectBox.setOnClickListener {
            bottomSheet = SelectionSheet(this , binding.tvSelectBox.text.toString())
            selectBox()
        }
        binding.tvVideoCount.tvSpinner.setOnClickListener {
            bottomSheetSpinner = SelectionSheetSpinner(this , binding.tvVideoCount.tvSpinner.text.toString(), type)
            selectSpinner()
        }

    }

    private fun selectBox() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheet.show(supportManager, bottomSheet.tag)
    }

    private fun selectSpinner() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetSpinner.show(supportManager, bottomSheetSpinner.tag)
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
    fun scrollToTop(){
        binding.rvVideo.smoothScrollToPosition(0)
    }

    override fun selection(value: String) {
        binding.tvSelectBox.text = value
        selectView = value
        page = 0
        onRefresh()
    }

    override fun selectionSpinner(value: String) {
        binding.tvVideoCount.tvSpinner.text = value
        selectOrder = value
        onRefresh()
    }
    private fun prepareData() {
        // 최초 호출
        Log.d(TAG, "prepareData...")
        when(selectView){
            Constants.CONTENT_VALUE_ALL ->{
                when(selectOrder){
                    Constants.CONTENT_VALUE_AVG ->  viewModel.loadVideo( Constants.GRADE_SORT_ID_SOCIETY, page, Constants.LIMIT_DEFAULT_INT, Constants.CONTENT_RESPONSE_VALUE_AVG)
                    Constants.CONTENT_VALUE_LATEST ->viewModel.loadVideo( Constants.GRADE_SORT_ID_SOCIETY, page, Constants.LIMIT_DEFAULT_INT,Constants.CONTENT_RESPONSE_VALUE_LATEST)
                    Constants.CONTENT_VALUE_NAME -> viewModel.loadVideo( Constants.GRADE_SORT_ID_SOCIETY, page, Constants.LIMIT_DEFAULT_INT,Constants.CONTENT_RESPONSE_VALUE_NAME)
                    Constants.CONTENT_VALUE_SUBJECT->viewModel.loadVideo( Constants.GRADE_SORT_ID_SOCIETY, page, Constants.LIMIT_DEFAULT_INT,Constants.CONTENT_RESPONSE_VALUE_SUBJECT)
                }
            }
            Constants.CONTENT_VALUE_SERIES ->{
                //            loadVideoSeries(page)
            }
            Constants.CONTENT_VALUE_PROBLEM ->{
                //            loadVideoProblem(page,Constants.SUBJECT_COMMENTARY_PROBLEM)
            }
            Constants.CONTENT_VALUE_NOTE ->{
                //            loadVideoNote(page)
            }
        }
        // 스크롤 이벤트
        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if (!isLoading && page != totalItemsCount && totalItemsCount >= 20) {
                    isLoading = true
                    load(totalItemsCount)
                }
            }
        }
        // 스크롤 이벤트 초기화
        binding.rvVideo.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun load(totalItemsCount: Int) {
        page = totalItemsCount
        if (isLoading) {
            mRecyclerAdapter.addLoading()
        }
        Handler().postDelayed({
            when(selectView){
                Constants.CONTENT_VALUE_ALL -> {
                    when(selectOrder){
                        Constants.CONTENT_VALUE_AVG ->  viewModel.loadVideo( Constants.GRADE_SORT_ID_SOCIETY, page, Constants.LIMIT_DEFAULT_INT, Constants.CONTENT_RESPONSE_VALUE_AVG)
                        Constants.CONTENT_VALUE_LATEST ->viewModel.loadVideo( Constants.GRADE_SORT_ID_SOCIETY, page, Constants.LIMIT_DEFAULT_INT,Constants.CONTENT_RESPONSE_VALUE_LATEST)
                        Constants.CONTENT_VALUE_NAME -> viewModel.loadVideo( Constants.GRADE_SORT_ID_SOCIETY, page, Constants.LIMIT_DEFAULT_INT,Constants.CONTENT_RESPONSE_VALUE_NAME)
                        Constants.CONTENT_VALUE_SUBJECT->viewModel.loadVideo( Constants.GRADE_SORT_ID_SOCIETY, page, Constants.LIMIT_DEFAULT_INT,Constants.CONTENT_RESPONSE_VALUE_SUBJECT)
                    }
                }
//                Constants.CONTENT_VALUE_SERIES -> if(page != totalItemsCount) loadVideoSeries(totalItemsCount)
//                Constants.CONTENT_VALUE_PROBLEM -> if(page != totalItemsCount) loadVideoProblem(totalItemsCount,Constants.SUBJECT_COMMENTARY_PROBLEM)
//                Constants.CONTENT_VALUE_NOTE -> if(page != totalItemsCount) loadMoreData(totalItemsCount,loadVideoNote(totalItemsCount))
            }
        }, Constants.DELAY_VALUE_OF_ENDLESS)
    }
}