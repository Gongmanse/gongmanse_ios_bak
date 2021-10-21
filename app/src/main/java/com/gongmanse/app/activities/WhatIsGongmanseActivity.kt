package com.gongmanse.app.activities

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.TableLayout
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.adapter.active.WhatIsGongmanseTabAdapter
import com.gongmanse.app.databinding.ActivityWhatIsGongmanseBinding
import com.gongmanse.app.fragments.whats.GongmanseStoryFragment
import com.gongmanse.app.fragments.whats.HowUseFragment
import com.gongmanse.app.fragments.whats.TeacherIntroFragment
import com.gongmanse.app.utils.Constants
import com.google.android.material.tabs.TabLayout

class WhatIsGongmanseActivity : AppCompatActivity() {

    companion object {
        private val TAG = WhatIsGongmanseActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityWhatIsGongmanseBinding
    private lateinit var mAdapter : WhatIsGongmanseTabAdapter
    private var currentFragment: Fragment? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_what_is_gongmanse)
        initView()
    }

    private fun initView() {
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_WHAT_S_GONGMANSE
        binding.layoutToolbar.btnClose.setOnClickListener {
            onBackPressed()
            finish()
        }
        mAdapter = WhatIsGongmanseTabAdapter(supportFragmentManager)
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
            when(currentFragment) {
                is GongmanseStoryFragment -> {
                    (currentFragment as GongmanseStoryFragment).scrollToTop()
                }
                is HowUseFragment -> {
                    (currentFragment as HowUseFragment).scrollToTop()
                }
                is TeacherIntroFragment -> {
                    (currentFragment as TeacherIntroFragment).scrollToTop()
                }
            }
        }

        override fun onTabSelected(tab: TabLayout.Tab?) {
            tab?.position?.let { currentFragment = mAdapter.getItem(it) }
        }
    }
}