package com.gongmanse.app.feature.main.home

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.gongmanse.app.R



import com.google.android.material.tabs.TabLayout
import kotlinx.android.synthetic.main.fragment_home.view.*


class HomeFragment : Fragment() {

    companion object {
        private val TAG = HomeFragment::class.java.simpleName
    }

    private lateinit var mContext: View

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        mContext = inflater.inflate(R.layout.fragment_home, container, false)
        initView()
        return mContext
    }

    override fun onHiddenChanged(hidden: Boolean) {
        super.onHiddenChanged(hidden)
        Log.d(TAG, "HomeFragment:: hidden => $hidden")
    }

    private fun initView() {
        Log.d(TAG, "HomeFragment:: initView()")
        val mAdapter = HomeTabAdapter(childFragmentManager)
        mContext.view_pager.adapter = mAdapter
        mContext.view_pager.offscreenPageLimit = mAdapter.count
        mContext.tab_layout.setupWithViewPager(mContext.view_pager)
        mContext.tab_layout.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener{
            override fun onTabReselected(tab: TabLayout.Tab?) {
                tab?.position?.let {
                    Log.d("it","$it")
                    when(it){
//                        0 -> (mAdapter.getItem(it) as HomeBestFragment).scrollToTop()
//                        1 -> (mAdapter.getItem(it) as HomeHotFragment).scrollToTop()
//                        2 -> (mAdapter.getItem(it) as HomeKEMFragment).scrollToTop()
//                        3 -> (mAdapter.getItem(it) as HomeScienceFragment).scrollToTop()
//                        4 -> (mAdapter.getItem(it) as HomeSocietyFragment).scrollToTop()
//                        5 -> (mAdapter.getItem(it) as HomeEtcFragment).scrollToTop()
                        else -> null
                    }
                }
            }
            override fun onTabUnselected(tab: TabLayout.Tab?) {}
            override fun onTabSelected(tab: TabLayout.Tab?) {}
        })
    }
}