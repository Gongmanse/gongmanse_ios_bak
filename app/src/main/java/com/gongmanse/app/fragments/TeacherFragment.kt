package com.gongmanse.app.fragments

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.activities.MainActivity
import com.gongmanse.app.adapter.teacher.TeacherTabAdapter
import com.gongmanse.app.fragments.home.*
import com.gongmanse.app.fragments.teacher.TeacherEFragment
import com.gongmanse.app.fragments.teacher.TeacherHFragment
import com.gongmanse.app.fragments.teacher.TeacherMFragment
import com.google.android.material.tabs.TabLayout
import kotlinx.android.synthetic.main.fragment_home.view.*
import kotlinx.android.synthetic.main.fragment_teacher.view.*
import kotlinx.android.synthetic.main.fragment_teacher.view.tab_layout
import kotlinx.android.synthetic.main.fragment_teacher.view.view_pager

class TeacherFragment : Fragment() {

    companion object {
        private val TAG = TeacherFragment::class.java.simpleName
    }

    private lateinit var mContext: View

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        mContext = inflater.inflate(R.layout.fragment_teacher, container, false)
        initView()
        return mContext
    }

    override fun onHiddenChanged(hidden: Boolean) {
        super.onHiddenChanged(hidden)
        Log.d(TAG, "TeacherFragment:: hidden => $hidden")

    }

    private fun initView() {
        Log.d(TAG, "TeacherFragment:: initView()")
        val mAdapter = TeacherTabAdapter(childFragmentManager)
        mContext.view_pager.adapter = mAdapter
        mContext.view_pager.offscreenPageLimit = mAdapter.count
        mContext.tab_layout.setupWithViewPager(mContext.view_pager)
        mContext.tab_layout.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener{
            override fun onTabReselected(tab: TabLayout.Tab?) {
                tab?.position?.let {
                    Log.d("it","$it")
                    when(it){
                        0 -> (mAdapter.getItem(it) as TeacherEFragment).scrollToTop()
                        1 -> (mAdapter.getItem(it) as TeacherMFragment).scrollToTop()
                        2 -> (mAdapter.getItem(it) as TeacherHFragment).scrollToTop()
                        else -> null
                    }
                }
            }
            override fun onTabUnselected(tab: TabLayout.Tab?) {}
            override fun onTabSelected(tab: TabLayout.Tab?) {}
        })
    }
}