package com.gongmanse.app.feature.main.teacher

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.databinding.FragmentTeacherBinding
import com.gongmanse.app.feature.main.teacher.tabs.TeacherListFragment
import com.google.android.material.tabs.TabLayout

class TeacherFragment : Fragment() {

    companion object {
        private val TAG = TeacherFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentTeacherBinding

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater,R.layout.fragment_teacher, container, false)
        initView()
        return binding.root
    }

    override fun onHiddenChanged(hidden: Boolean) {
        super.onHiddenChanged(hidden)
        Log.d(TAG, "TeacherFragment:: hidden => $hidden")

    }

    private fun initView() {
        Log.d(TAG, "TeacherFragment:: initView()")
        val mAdapter = TeacherTabAdapter(childFragmentManager)
        binding.viewPager.adapter = mAdapter
        binding.viewPager.offscreenPageLimit = mAdapter.count
        binding.tabLayout.setupWithViewPager(binding.viewPager)
        binding.tabLayout.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener{
            override fun onTabReselected(tab: TabLayout.Tab?) {
                tab?.position?.let {
                    Log.d("it","$it")
                    when(it){
                        0 -> (mAdapter.getItem(it) as TeacherListFragment).scrollToTop()
//                        1 -> (mAdapter.getItem(it) as TeacherMFragment).scrollToTop()
//                        2 -> (mAdapter.getItem(it) as TeacherHFragment).scrollToTop()
                        else -> null
                    }
                }
            }
            override fun onTabUnselected(tab: TabLayout.Tab?) {}
            override fun onTabSelected(tab: TabLayout.Tab?) {}
        })
    }
}