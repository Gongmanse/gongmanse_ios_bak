package com.gongmanse.app.adapter.active

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.gongmanse.app.fragments.whats.GongmanseStoryFragment
import com.gongmanse.app.fragments.whats.HowUseFragment
import com.gongmanse.app.fragments.whats.TeacherIntroFragment
import com.gongmanse.app.utils.Constants

class WhatIsGongmanseTabAdapter(fm: FragmentManager) : FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    companion object {
        private val TAG = WhatIsGongmanseTabAdapter::class.java.simpleName
    }

    private val fragments = ArrayList<Fragment>()

    init {
        fragments.add(GongmanseStoryFragment())
        fragments.add(HowUseFragment())
        fragments.add(TeacherIntroFragment())

    }



    override fun getItem(position: Int): Fragment {
        return fragments[position]
    }

    override fun getCount(): Int = fragments.size

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> Constants.WHAT_TAB_TITLE_STORY
            1 -> Constants.WHAT_TAB_TITLE_HOW_USE
            2 -> Constants.WHAT_TAB_TITLE_TEACHER_INTRO
            else -> null
        }
    }
}