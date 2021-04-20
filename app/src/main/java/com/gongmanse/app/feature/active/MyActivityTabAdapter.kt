package com.gongmanse.app.feature.active

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.gongmanse.app.utils.Constants

class MyActivityTabAdapter(fm: FragmentManager) : FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    private val tabTitleList = arrayOf(
        Constants.Activity.ACTIVITY_RECENT_VIDEO,
        Constants.Activity.ACTIVITY_NOTE,
        Constants.Activity.ACTIVITY_QNA,
        Constants.Activity.ACTIVITY_QUESTION,
        Constants.Activity.ACTIVITY_BOOK_MARK
    )

    private val tabList = arrayOf(
        MyRecentVideoFragment(),
        MyNoteFragment(),
        MyRecentVideoFragment(),
        MyNoteFragment(),
        MyRecentVideoFragment()
    )

    override fun getCount(): Int {
        return tabTitleList.size
    }

    override fun getPageTitle(position: Int): CharSequence {
        return tabTitleList[position]
    }

    override fun getItem(position: Int): Fragment {
        return tabList[position]
    }
}