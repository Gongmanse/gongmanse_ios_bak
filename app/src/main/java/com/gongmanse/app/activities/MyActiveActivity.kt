package com.gongmanse.app.activities

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.adapter.active.MyActiveTabAdapter
import com.gongmanse.app.databinding.ActivityMyActiveBinding
import com.gongmanse.app.fragments.active.*
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.google.android.material.tabs.TabLayout
import org.koin.android.ext.android.bind

class MyActiveActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = MyActiveActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityMyActiveBinding
    private lateinit var mAdapter: MyActiveTabAdapter
    private var currentFragment: Fragment? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_my_active)
        initView()
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            // 닫기
            R.id.btn_close -> Commons.close(this)
            // 지우기
            R.id.btn_remove -> {
                when (currentFragment) {
                    is ActiveRecentVideoFragment -> {
                        Log.e(TAG, "fragment1")
                        (currentFragment as ActiveRecentVideoFragment).setRemoveMode()
                    }
                    is ActiveNoteFragment -> {
                        Log.e(TAG, "fragment2")
                        (currentFragment as ActiveNoteFragment).setRemoveMode()
                    }
                    is ActiveQNAFragment -> {
                        Log.e(TAG, "fragment3")
                        (currentFragment as ActiveQNAFragment).setRemoveMode()
                    }
                    is ActiveQuestionFragment -> {
                        Log.e(TAG, "fragment4")
                        (currentFragment as ActiveQuestionFragment).setRemoveMode()
                    }
                    is ActiveFavoritesFragment -> {
                        Log.e(TAG, "fragment5")
                        (currentFragment as ActiveFavoritesFragment).setRemoveMode()
                    }
                }
            }
        }
    }

    private fun initView() {
        binding.title = Constants.ACTIONBAR_TITLE_MY_ACTIVITY
        mAdapter = MyActiveTabAdapter(supportFragmentManager)
        binding.tabLayout.addOnTabSelectedListener(onTabSelectedListener)
        binding.viewPager.apply {
            adapter = mAdapter
            offscreenPageLimit = mAdapter.count
            binding.tabLayout.setupWithViewPager(this)
        }
    }

    private val onTabSelectedListener = object: TabLayout.OnTabSelectedListener {
        override fun onTabUnselected(tab: TabLayout.Tab?) {
            when (currentFragment) {
                is ActiveRecentVideoFragment -> {
                    Log.e(TAG, "fragment1")
                    (currentFragment as ActiveRecentVideoFragment).setNormalMode()
                }
                is ActiveNoteFragment -> {
                    Log.e(TAG, "fragment2")
                    (currentFragment as ActiveNoteFragment).setNormalMode()
                }
                is ActiveQNAFragment -> {
                    Log.e(TAG, "fragment3")
                    (currentFragment as ActiveQNAFragment).setNormalMode()
                }
                is ActiveQuestionFragment -> {
                    Log.e(TAG, "fragment4")
                    (currentFragment as ActiveQuestionFragment).setNormalMode()
                }
                is ActiveFavoritesFragment -> {
                    Log.e(TAG, "fragment5")
                    (currentFragment as ActiveFavoritesFragment).setNormalMode()
                }
            }
        }
        override fun onTabReselected(tab: TabLayout.Tab?) {
            when (currentFragment) {
                is ActiveRecentVideoFragment -> {
                    Log.e(TAG, "fragment1")
                    (currentFragment as ActiveRecentVideoFragment).moveTopPosition()
                }
                is ActiveNoteFragment -> {
                    Log.e(TAG, "fragment2")
                    (currentFragment as ActiveNoteFragment).moveTopPosition()
                }
                is ActiveQNAFragment -> {
                    Log.e(TAG, "fragment3")
                    (currentFragment as ActiveQNAFragment).moveTopPosition()
                }
                is ActiveQuestionFragment -> {
                    Log.e(TAG, "fragment4")
                    (currentFragment as ActiveQuestionFragment).moveTopPosition()
                }
                is ActiveFavoritesFragment -> {
                    Log.e(TAG, "fragment5")
                    (currentFragment as ActiveFavoritesFragment).moveTopPosition()
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