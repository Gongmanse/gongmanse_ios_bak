package com.gongmanse.app.fragments.progress

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.adapter.progress.ProgressTabPagerAdapter
import com.gongmanse.app.databinding.FragmentProgressBinding
import com.gongmanse.app.utils.Preferences
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
        initView()
        return binding.root
    }

    override fun onResume() {
        super.onResume()
        Log.v(TAG, "onResume")
        initView()
    }

    override fun onStart() {
        super.onStart()
        Log.v(TAG, "onStart")
        initView()
    }

    private fun initView() {
        mAdapter = ProgressTabPagerAdapter(childFragmentManager)
        binding.tabLayout.addOnTabSelectedListener(onTabSelectedListener)
        binding.viewPager.apply {
            adapter = mAdapter
            offscreenPageLimit = mAdapter.count
            binding.tabLayout.setupWithViewPager(this)
        }
    }

    private val onTabSelectedListener = object : TabLayout.OnTabSelectedListener {

        override fun onTabUnselected(tab: TabLayout.Tab?) {}

        override fun onTabReselected(tab: TabLayout.Tab?) {
            when (currentFragment) {
                is ProgressKEMFragment -> {
                    Log.d(TAG, "ProgressKEMFragment")
                    (currentFragment as ProgressKEMFragment).scrollToTop()
                }
                is ProgressScienceFragment -> {
                    Log.d(TAG, "ProgressScienceFragment")
                    (currentFragment as ProgressScienceFragment).scrollToTop()
                }

                is ProgressSocietyFragment -> {
                    Log.d(TAG, "ProgressSocietyFragment")
                    (currentFragment as ProgressSocietyFragment).scrollToTop()
                }

                is ProgressEtcFragment -> {
                    Log.d(TAG, "ProgressEtcFragment")
                    (currentFragment as ProgressEtcFragment).scrollToTop()
                }
            }
        }

        override fun onTabSelected(tab: TabLayout.Tab?) {
            tab?.position?.let {
                currentFragment = mAdapter.getItem(it)
            }
        }
    }

    fun updateGradeAndSubject() {
        Log.v(TAG, "updateGradeAndSubject()")
        initView()
    }
}