package com.gongmanse.app.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import androidx.viewpager2.adapter.FragmentStateAdapter

class ViewPagerAdapter(fm: FragmentManager, lifecycle: Lifecycle): FragmentStateAdapter(fm, lifecycle) {

    private val mViewList = arrayListOf<Fragment>()

    fun addFragment(fragment: Fragment) {
        mViewList.add(fragment)
    }

    override fun createFragment(position: Int): Fragment {
        return mViewList[position]
    }

    override fun getItemCount(): Int {
        return mViewList.size
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

}