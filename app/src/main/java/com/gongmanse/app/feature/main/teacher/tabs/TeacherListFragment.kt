package com.gongmanse.app.feature.main.teacher.tabs

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
import com.gongmanse.app.R
import com.gongmanse.app.data.network.teacher.TeacherRepository
import com.gongmanse.app.databinding.FragmentTeacherTapBinding
import com.gongmanse.app.feature.main.teacher.TeacherViewModel
import com.gongmanse.app.feature.main.teacher.TeacherViewModelFactory
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.EndlessRVScrollListener


class TeacherListFragment(private val grade : String) : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = TeacherListFragment::class.java.simpleName
    }

    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var binding: FragmentTeacherTapBinding
    private lateinit var mRecyclerAdapterList : TeacherListRvAdapter
    private lateinit var teacherModel : TeacherViewModel
    private lateinit var mTeacherViewModelFactory: TeacherViewModelFactory
    private val linearLayoutManager = LinearLayoutManager(context)
    private var mOffset : Int = Constants.DefaultValue.OFFSET_INT
    private var mLimit : Int = Constants.DefaultValue.LIMIT_INT
    private var isLoading = false


    override fun onRefresh() {
        mOffset = 0
        teacherModel.liveDataClear()
        mRecyclerAdapterList.clear()
        isLoading = false
        binding.refreshLayout.isRefreshing = false
        prepareData()
    }

    override fun onCreateView(inflater: LayoutInflater,container: ViewGroup?,savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_teacher_tap, container, false)
        initView()
        prepareData()
        return binding.root
    }

    fun scrollToTop(){
        binding.rvVideo.smoothScrollToPosition(0)
    }

    private fun initView() {
        binding.refreshLayout.setOnRefreshListener(this)
        binding.refreshLayout.isRefreshing = false
        if (::mTeacherViewModelFactory.isInitialized.not()) {
            mTeacherViewModelFactory = TeacherViewModelFactory(TeacherRepository())
        }
        if (::teacherModel.isInitialized.not()) {
            teacherModel = ViewModelProvider(this, mTeacherViewModelFactory).get(TeacherViewModel::class.java)
        }
        teacherModel = ViewModelProvider(this).get(TeacherViewModel::class.java)
        teacherModel.currentValue.observe( viewLifecycleOwner){
            if(isLoading) mRecyclerAdapterList.removeLoading()
            mRecyclerAdapterList.addItems(it)
            isLoading = false
        }
        setRVLayout()
    }

    private fun setRVLayout() {
        binding.rvVideo.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            val linearLayout = LinearLayoutManager(context)
            linearLayout.orientation = LinearLayoutManager.VERTICAL
            layoutManager = linearLayoutManager
        }
        if (binding.rvVideo.adapter == null) {
            mRecyclerAdapterList = TeacherListRvAdapter()
            binding.rvVideo.adapter = mRecyclerAdapterList
        }
    }

    private fun prepareData() {
        teacherModel.getTeacher(grade,mOffset,mLimit)
        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if (!isLoading && mOffset != totalItemsCount && totalItemsCount >= 20){
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
        if (isLoading) {
            mRecyclerAdapterList.addLoading()
        }
        Handler(Looper.getMainLooper()).postDelayed({
            mOffset = offset
            teacherModel.getTeacher(grade,mOffset,mLimit)
        }, Constants.Delay.VALUE_OF_ENDLESS)

    }
}