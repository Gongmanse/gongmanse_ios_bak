package com.gongmanse.app.adapter.teacher

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentStatePagerAdapter
import com.gongmanse.app.fragments.teacher.TeacherEFragment
import com.gongmanse.app.fragments.teacher.TeacherHFragment
import com.gongmanse.app.fragments.teacher.TeacherMFragment
import com.gongmanse.app.utils.Constants

class TeacherTabAdapter(fm: FragmentManager): FragmentStatePagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    private val fragments = ArrayList<Fragment>()

    init {
        fragments.add(TeacherEFragment())
        fragments.add(TeacherMFragment())
        fragments.add(TeacherHFragment())
    }

    override fun getItem(position: Int): Fragment {
        return fragments[position]
    }

    override fun getCount() = fragments.size

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> Constants.CONTENT_VALUE_ELEMENTARY
            1 -> Constants.CONTENT_VALUE_MIDDLE
            2 -> Constants.CONTENT_VALUE_HIGH
            else -> null
        }
    }
}