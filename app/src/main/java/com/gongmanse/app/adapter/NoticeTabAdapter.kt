package com.gongmanse.app.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.gongmanse.app.fragments.notice.NoticeEventFragment
import com.gongmanse.app.fragments.notice.NoticeFragment
import com.gongmanse.app.utils.Constants

class NoticeTabAdapter (fm: FragmentManager): FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    companion object {
        private val TAG = NoticeTabAdapter::class.java.simpleName
    }

    private val fragments = ArrayList<Fragment>()

    init {
        fragments.add(NoticeFragment())
        fragments.add(NoticeEventFragment())
    }

    override fun getItem(position: Int): Fragment {
        return fragments[position]
    }

    override fun getCount() = fragments.size

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> Constants.NOTICE_TAB_TITLE_NOTICE
            1 -> Constants.NOTICE_TAB_TITLE_EVENT
            else -> null
        }
    }
}