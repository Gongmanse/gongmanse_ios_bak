@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.main.progress

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.DividerItemDecoration
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
import com.gongmanse.app.utils.Preferences
import com.gongmanse.app.utils.listeners.OnBottomSheetToUnitListener
import kotlinx.android.synthetic.main.activity_main.view.*
import org.jetbrains.anko.support.v4.toast


class ProgressListFragment(private val subject : Int?) : Fragment(), SwipeRefreshLayout.OnRefreshListener, OnBottomSheetToUnitListener {

    companion object {
        private val TAG = ProgressListFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentProgressListBinding
    private lateinit var mAdapter: ProgressRVAdapter
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mProgressViewModel: ProgressViewModel
    private lateinit var mProgressViewModelFactory: ProgressViewModelFactory
    private lateinit var bottomSheetSelectionUnits: SelectionSheetUnits

    private var isLoading = false
    private var mOffset: Int = 0
    private var grade: String = Constants.GradeType.All_GRADE
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

    override fun onSelectionUnits(key: Int?, id: Int?, units: String?) {
        Log.e(TAG, "onSelectionUnits Key:$key, id:$id, units:$units")
        if (key != null) {
            Constants.SelectValue.apply {
                when (key) {
                    SORT_ITEM_TYPE_GRADE -> {
                        bottomSheetSelectionUnits.dismiss()
                        updateGradeText(units, units, Constants.Progress.SORT_ALL_UNIT)
                        binding.tvSelectGrade.text = gradeTitle

                        Commons.apply { updateGradeInfo(checkGrade(units), checkGradeNum(units)) }

                        loadProgressList()
                    }
                    SORT_ITEM_TYPE_UNITS -> {
                        bottomSheetSelectionUnits.dismiss()
                    }
                }
            }
        } else Log.e(TAG, "onSelectionUnits is null")
    }

    fun scrollToTop() = binding.rvProgressList.smoothScrollToPosition(0)

    private fun initView() {
        binding.apply {
            layoutRefresh.setOnRefreshListener(this@ProgressListFragment)
            layoutEmpty.title = resources.getString(R.string.empty_progress)
            tvSelectGrade.setOnClickListener {
                bottomSheetManager(null, this@ProgressListFragment, Constants.SelectValue.SORT_ITEM_TYPE_GRADE, gradeTitle)
            }
            tvSelectUnit.setOnClickListener  {
                val query: HashMap<String, Any?> = hashMapOf(
                    Constants.Extra.KEY_SUBJECT to subject,
                    Constants.Extra.KEY_GRADE to grade,
                    Constants.Extra.KEY_GRADE_NUM to gradeNum.toString()
                )
                if (grade.isEmpty()) toast(getString(R.string.content_toast_plz_check_grade))
                else bottomSheetManager(query, this@ProgressListFragment, Constants.SelectValue.SORT_ITEM_TYPE_UNITS, Constants.Init.INIT_STRING)
            }
        }
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

    private fun bottomSheetManager(
        query: HashMap<String, Any?>?,
        listener: OnBottomSheetToUnitListener,
        item_type: Int,
        select_text: String,
    ) {
        val supportManager = (context as FragmentActivity).supportFragmentManager
        bottomSheetSelectionUnits = SelectionSheetUnits(query, listener, item_type, select_text)
        bottomSheetSelectionUnits.show(supportManager, bottomSheetSelectionUnits.tag)
    }

    private fun selectedSetting() {
        if (Preferences.grade.isNotEmpty()) {
            Preferences.grade.apply { updateGradeText(this, this, Constants.Progress.SORT_ALL_UNIT) }
            Commons.apply { updateGradeInfo(checkGrade(grade), checkGradeNum(grade)) }
        } else {
            updateGradeInfo(null, null)
            Constants.GradeType.apply { updateGradeText(All_GRADE, All_GRADE, Constants.Progress.SORT_ALL_UNIT) }
        }
    }

    private fun initRVLayout() {
        binding.rvProgressList.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            mAdapter = ProgressRVAdapter()
            adapter  = mAdapter
            layoutManager = linearLayoutManager
            addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL))
        }
    }

    private fun updateGradeInfo(grades: String?, grade_num: Int?) {
        if (grades != null)    grade    = grades    else Log.e(TAG,"updateGradeInfo grade is null")
        if (grade_num != null) gradeNum = grade_num else Log.e(TAG, "updateGradeInfo grade_num is null")
    }

    private fun updateGradeText(grade_title: String?, select_grade: String?, select_unit: String?) {
        if (grade_title != null) gradeTitle = grade_title else Log.e(TAG,"gradeTitle is null")
        binding.apply {
            if (select_grade != null) binding.tvSelectGrade.text = select_grade
            if (select_unit != null)  binding.tvSelectUnit.text  = select_unit
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
        mProgressViewModel.loadProgressList(subject, grade, gradeNum, mOffset)
    }

}