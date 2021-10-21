package com.gongmanse.app.adapter.progress

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentStatePagerAdapter
import com.gongmanse.app.fragments.progress.*
import com.gongmanse.app.utils.Constants


class ProgressTabPagerAdapter(fm: FragmentManager) :
    FragmentStatePagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    private val fragments = ArrayList<Fragment>()

    init {
        fragments.add(ProgressKEMFragment())
        fragments.add(ProgressScienceFragment())
        fragments.add(ProgressSocietyFragment())
        fragments.add(ProgressEtcFragment())
    }

//    init {
//        fragments.add(ProgressListFragment(Constants.GRADE_SORT_ID_KEM))
//        fragments.add(ProgressListFragment(Constants.GRADE_SORT_ID_SCIENCE))
//        fragments.add(ProgressListFragment(Constants.GRADE_SORT_ID_SOCIETY))
//        fragments.add(ProgressListFragment(Constants.GRADE_SORT_ID_ETC))
//    }

    override fun getItem(position: Int): Fragment {
        return fragments[position]
    }

    override fun getCount() = fragments.size

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> Constants.PROGRESS_TAB_TITLE_KEM
            1 -> Constants.PROGRESS_TAB_TITLE_SCIENCE
            2 -> Constants.PROGRESS_TAB_TITLE_SOCIETY
            3 -> Constants.PROGRESS_TAB_TITLE_ETC
            else -> null
        }
    }
}