@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.main.progress

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.databinding.FragmentProgressBinding
import com.gongmanse.app.feature.main.progress.adapter.ProgressTabPagerAdapter
import com.google.android.material.tabs.TabLayout

class ProgressFragment : Fragment() {

    companion object {
        private val TAG = ProgressFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentProgressBinding
    private lateinit var mAdapter: ProgressTabPagerAdapter
    private var currentFragment: Fragment? = null

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_progress, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onResume() {
        super.onResume()
        Log.v(TAG, "onResume")
    }

    override fun onStart() {
        super.onStart()
        Log.v(TAG, "onStart")
    }

    private fun initView() {
        mAdapter = ProgressTabPagerAdapter(childFragmentManager)
        binding.apply {
            tabLayoutProgress.addOnTabSelectedListener(onTabSelectedListener)
            vpProgress.apply {
                adapter = mAdapter
                offscreenPageLimit = mAdapter.count
                tabLayoutProgress.setupWithViewPager(this)
            }
        }
    }

    private val onTabSelectedListener = object : TabLayout.OnTabSelectedListener {

        override fun onTabUnselected(tab: TabLayout.Tab?) {}

        override fun onTabReselected(tab: TabLayout.Tab?) {
            when(currentFragment) {
                is ProgressKEMFragment     -> {}
                is ProgressScienceFragment -> {}
                is ProgressSocietyFragment -> {}
                is ProgressEtcFragment     -> {}
            }
        }

        override fun onTabSelected(tab: TabLayout.Tab?) {
            tab?.position?.let {
                currentFragment = mAdapter.getItem(it)
            }
        }
    }

}