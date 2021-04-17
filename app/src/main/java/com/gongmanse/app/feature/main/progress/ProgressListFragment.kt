@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.main.progress

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.R
import com.gongmanse.app.data.network.progress.ProgressRepository
import com.gongmanse.app.databinding.FragmentProgressListBinding
import com.gongmanse.app.feature.main.progress.adapter.ProgressRVAdapter
import com.gongmanse.app.feature.sheet.SelectionSheetUnits
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.EndlessRVScrollListener
import kotlinx.android.synthetic.main.activity_main.view.*


class ProgressListFragment(private val subject : Int?) : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = ProgressListFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentProgressListBinding
    private lateinit var mAdapter: ProgressRVAdapter
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mProgressViewModel: ProgressViewModel
    private lateinit var mProgressViewModelFactory: ProgressViewModelFactory
    private lateinit var bottomSheetUnits: SelectionSheetUnits

    private var isLoading = false
    private var mOffset: Int = 0
    private var grade: String = Constants.Init.INIT_STRING
    private var gradeNum: Int = Constants.Init.INIT_INT
    private var gradeTitle: String = Constants.Init.INIT_STRING
    private var progressTitle = Constants.Init.INIT_STRING
    private val linearLayoutManager = LinearLayoutManager(context)

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_progress_list, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onRefresh() {
        mAdapter.clear()
        isLoading = false
        binding.layoutRefresh.isRefreshing = false
        prepareData()
    }

    fun scrollToTop() = binding.rvProgressList.smoothScrollToPosition(0)

    private fun initView() {
        binding.layoutRefresh.setOnRefreshListener(this)
        binding.layoutEmpty.title = resources.getString(R.string.empty_progress)

        binding.tvSelectGrade.setOnClickListener { Commons.bottomSheetManager(Constants.SelectValue.SORT_ITEM_TYPE_GRADE, gradeTitle, binding.root.context) }

        initViewModel()
        selectedSetting()
        initRVLayout()
        prepareData()
    }


    private fun initViewModel() {
        if (::mProgressViewModelFactory.isInitialized.not()) mProgressViewModelFactory = ProgressViewModelFactory(ProgressRepository())
        if (::mProgressViewModel.isInitialized.not()) mProgressViewModel = ViewModelProvider(this, mProgressViewModelFactory).get(ProgressViewModel::class.java)

        mProgressViewModel.currentProgress.observe( this, {
            if (isLoading) mAdapter.removeLoading()
            mAdapter.addItems(it)
            isLoading = false
        })

    }

    private fun selectedSetting() {}

    private fun initRVLayout() {
        binding.rvProgressList.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            mAdapter = ProgressRVAdapter()
            adapter  = mAdapter
            layoutManager = linearLayoutManager
        }
    }



    private fun prepareData() {
        // 최초 호출
        loadProgressList()

        // 스크롤: Listener 설정
        scrollListener = object : EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if (!isLoading && mOffset != totalItemsCount && totalItemsCount >= Constants.DefaultValue.LIMIT_INT) {
                    isLoading = true
                    loadMoreData(totalItemsCount)
                }
            }
        }

        // 스크롤: 이벤트 초기화
        binding.rvProgressList.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(totalItemsCount: Int) {
        mOffset = totalItemsCount
        if (isLoading) {
            mAdapter.addLoading()
        }
        Handler(Looper.getMainLooper()).postDelayed({
            loadProgressList()
        }, Constants.Delay.VALUE_OF_ENDLESS)

    }


    private fun loadProgressList() {
        grade = "모든"
        gradeNum = 0
        mProgressViewModel.loadProgressList(subject, grade, gradeNum, mOffset)
    }

}