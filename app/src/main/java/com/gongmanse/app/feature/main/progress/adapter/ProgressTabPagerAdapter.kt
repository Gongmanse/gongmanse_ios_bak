@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.main.progress.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentStatePagerAdapter
import com.gongmanse.app.feature.main.progress.*
import com.gongmanse.app.utils.Constants


class ProgressTabPagerAdapter(fm: FragmentManager) : FragmentStatePagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    private val fragment = ArrayList<Fragment>()

    init {
        fragment.add(ProgressListFragment(Constants.SubjectValue.KEM))
        fragment.add(ProgressListFragment(Constants.SubjectValue.SCIENCE))
        fragment.add(ProgressListFragment(Constants.SubjectValue.SOCIETY))
        fragment.add(ProgressListFragment(Constants.SubjectValue.ETC))
    }

    override fun getCount() = fragment.size

    override fun getItem(position: Int): Fragment {
       return fragment[position]
    }

    override fun getPageTitle(position: Int): CharSequence? {
            return when(position) {
                0 -> Constants.Progress.TAB_TITLE_KEM
                1 -> Constants.Progress.TAB_TITLE_SCIENCE
                2 -> Constants.Progress.TAB_TITLE_SOCIETY
                3 -> Constants.Progress.TAB_TITLE_ETC
                else -> null
            }
    }
}