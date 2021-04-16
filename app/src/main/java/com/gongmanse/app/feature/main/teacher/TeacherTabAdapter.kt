@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.main.teacher

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentStatePagerAdapter
import com.gongmanse.app.feature.main.teacher.tabs.TeacherListFragment
import com.gongmanse.app.utils.Constants

class TeacherTabAdapter(fm: FragmentManager): FragmentStatePagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    private val fragments = ArrayList<Fragment>()

    init {
        fragments.add(TeacherListFragment(Constants.GradeType.ELEMENTARY))
        fragments.add(TeacherListFragment(Constants.GradeType.MIDDLE))
        fragments.add(TeacherListFragment(Constants.GradeType.HIGH))
    }

    override fun getItem(position: Int): Fragment {
        return fragments[position]
    }

    override fun getCount() = fragments.size

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> Constants.Teacher.TAB_TITLE_ELEMENTARY
            1 -> Constants.Teacher.TAB_TITLE_MIDDLE
            2 -> Constants.Teacher.TAB_TITLE_HIGH
            else -> null
        }
    }
}

