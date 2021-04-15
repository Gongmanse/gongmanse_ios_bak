package com.gongmanse.app.feature.main.home.tabs

import android.os.Bundle
import android.os.Handler
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
import com.gongmanse.app.data.model.video.VideoBody
import com.gongmanse.app.databinding.FragmentSubjectBinding
import com.gongmanse.app.feature.main.LiveDataVideo
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
    private var mOffset: Int = Constants.DefaultValue.OFFSET_INT                                 // api 페이지
    private var isLoading = false
    private val type = 3
    private var selectView: String = Constants.SelectValue.SORT_ALL         // select 박스 기본값
    private var selectOrder: String = Constants.SelectValue.SORT_AVG        // 정렬 기본값
    private val linearLayoutManager = LinearLayoutManager(context)

    private lateinit var viewModel: LiveDataVideo


    override fun onRefresh() {
        mOffset = 0
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
        binding.setVariable(BR.title,Constants.Home.TAB_TITLE_KEM)
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

    override fun selectedSortBoxValue(value: String) {
        binding.tvSelectBox.text = value
        selectView = value
        mOffset = 0
        when(value){
            Constants.SelectValue.SORT_ALL -> VideoBody.setView(Constants.ViewType.DEFAULT)
            Constants.SelectValue.SORT_SERIES -> VideoBody.setView(Constants.ViewType.SERIES)
            Constants.SelectValue.SORT_PROBLEM -> VideoBody.setView(Constants.ViewType.DEFAULT)
            Constants.SelectValue.SORT_NOTE -> VideoBody.setView(Constants.ViewType.NOTE)
        }
        onRefresh()
    }

    override fun selectedSortSpinnerValue(value: String) {
        binding.tvVideoCount.tvSpinner.text = value
        selectOrder = value
        onRefresh()
    }

    private fun prepareData() {
        when(selectView){
            Constants.SelectValue.SORT_ALL ->{
                when(selectOrder){
                    Constants.SelectValue.SORT_AVG      -> viewModel.loadVideo( Constants.SubjectValue.SOCIETY, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_AVG, Constants.SubjectType.DEFAULT)
                    Constants.SelectValue.SORT_LATEST   -> viewModel.loadVideo( Constants.SubjectValue.SOCIETY, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_LATEST, Constants.SubjectType.DEFAULT)
                    Constants.SelectValue.SORT_NAME     -> viewModel.loadVideo( Constants.SubjectValue.SOCIETY, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_NAME, Constants.SubjectType.DEFAULT)
                    Constants.SelectValue.SORT_SUBJECT  -> viewModel.loadVideo( Constants.SubjectValue.SOCIETY, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_SUBJECT, Constants.SubjectType.DEFAULT)
                }
            }
            Constants.SelectValue.SORT_SERIES ->{
                viewModel.loadVideo(Constants.SubjectValue.SOCIETY,mOffset, Constants.DefaultValue.LIMIT_INT,null,Constants.SubjectType.SERIES)
            }
            Constants.SelectValue.SORT_PROBLEM ->{
                viewModel.loadVideo(Constants.SubjectValue.SOCIETY,mOffset, Constants.DefaultValue.LIMIT_INT,null,Constants.SubjectType.PROBLEM)
            }
            Constants.SelectValue.SORT_NOTE ->{
                viewModel.loadVideo(Constants.SubjectValue.SOCIETY,mOffset, Constants.DefaultValue.LIMIT_INT,null,Constants.SubjectType.NOTE)
            }
        }
        // 스크롤 이벤트
        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if (!isLoading && mOffset != totalItemsCount && totalItemsCount >= 20) {
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
        mOffset = totalItemsCount
        if (isLoading) {
            mRecyclerAdapter.addLoading()
        }
        Handler().postDelayed({
            when(selectView){
                Constants.SelectValue.SORT_ALL -> {
                    when(selectOrder){
                        Constants.SelectValue.SORT_AVG      -> viewModel.loadVideo( Constants.SubjectValue.SOCIETY, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_AVG, Constants.SubjectType.DEFAULT )
                        Constants.SelectValue.SORT_LATEST   -> viewModel.loadVideo( Constants.SubjectValue.SOCIETY, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_LATEST, Constants.SubjectType.DEFAULT)
                        Constants.SelectValue.SORT_NAME     -> viewModel.loadVideo( Constants.SubjectValue.SOCIETY, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_NAME, Constants.SubjectType.DEFAULT)
                        Constants.SelectValue.SORT_SUBJECT  -> viewModel.loadVideo( Constants.SubjectValue.SOCIETY, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_SUBJECT, Constants.SubjectType.DEFAULT)
                    }
                }
                Constants.SelectValue.SORT_SERIES -> viewModel.loadVideo(Constants.SubjectValue.SOCIETY,mOffset, Constants.DefaultValue.LIMIT_INT,null,Constants.SubjectType.SERIES)
                Constants.SelectValue.SORT_PROBLEM -> viewModel.loadVideo(Constants.SubjectValue.SOCIETY,mOffset, Constants.DefaultValue.LIMIT_INT,null,Constants.SubjectType.PROBLEM)
                Constants.SelectValue.SORT_NOTE -> viewModel.loadVideo(Constants.SubjectValue.SOCIETY,mOffset, Constants.DefaultValue.LIMIT_INT,null,Constants.SubjectType.NOTE)
            }
        }, Constants.Delay.VALUE_OF_ENDLESS)
    }
}