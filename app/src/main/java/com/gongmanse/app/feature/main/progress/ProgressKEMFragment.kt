@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.main.progress

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.R
import com.gongmanse.app.databinding.FragmentProgressKemBinding
import com.gongmanse.app.feature.main.progress.adapter.ProgressRVAdapter
import com.gongmanse.app.utils.Constants


class ProgressKEMFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = ProgressFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentProgressKemBinding
    private lateinit var mAdapter: ProgressRVAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_progress_kem, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onRefresh() {
        binding.layoutRefresh.isRefreshing = false
        mAdapter.clear()
        prepareData()
    }

    fun scrollToTop() = binding.rvKemList.smoothScrollToPosition(0)

    private fun initView() {
        selectedSetting()
        initRVLayout()
        prepareData()

    }

    private fun selectedSetting() {}

    private fun initRVLayout() {}

    private fun prepareData() {}
}