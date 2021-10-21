package com.gongmanse.app.activities

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.adapter.NoticeTabAdapter
import com.gongmanse.app.databinding.ActivityNoticeBinding
import com.gongmanse.app.fragments.notice.NoticeEventFragment
import com.gongmanse.app.fragments.notice.NoticeFragment
import com.gongmanse.app.fragments.search.SearchHotFragment
import com.gongmanse.app.fragments.search.SearchMainFragment
import com.gongmanse.app.fragments.search.SearchRecentFragment
import com.gongmanse.app.utils.Constants
import com.google.android.material.tabs.TabLayout

class NoticeActivity : AppCompatActivity() {

    companion object {
        private val TAG = NoticeActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityNoticeBinding
    private lateinit var mAdapter: NoticeTabAdapter
    private var currentFragment: Fragment? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_notice)
        initView()
    }

    private fun initView() {
        binding.layoutToolbar.title  = Constants.ACTIONBAR_TITLE_NOTICE
        binding.layoutToolbar.btnClose.setOnClickListener {
            onBackPressed()
            finish()
        }
        mAdapter = NoticeTabAdapter(supportFragmentManager)
        binding.viewPager.apply {
            adapter = mAdapter
            offscreenPageLimit = mAdapter.count
            binding.tabLayout.setupWithViewPager(this)
            binding.tabLayout.addOnTabSelectedListener(onTabSelectedListener)
        }
    }

    private val onTabSelectedListener = object : TabLayout.OnTabSelectedListener {
        override fun onTabUnselected(tab: TabLayout.Tab?) {}

        override fun onTabReselected(tab: TabLayout.Tab?) {
            when(currentFragment) {
                is NoticeFragment -> {
                    (currentFragment as NoticeFragment).scrollToTop()
                }
                is NoticeEventFragment -> {
                    (currentFragment as NoticeEventFragment).scrollToTop()
                }
            }
        }
        override fun onTabSelected(tab: TabLayout.Tab?) {
            tab?.position?.let {
                currentFragment = mAdapter.getItem(it)
            }
        }
    }
}