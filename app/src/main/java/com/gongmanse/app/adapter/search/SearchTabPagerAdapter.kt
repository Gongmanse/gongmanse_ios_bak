package com.gongmanse.app.adapter.search

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentStatePagerAdapter
import com.gongmanse.app.fragments.search.SearchHotFragment
import com.gongmanse.app.fragments.search.SearchRecentFragment
import com.gongmanse.app.utils.Constants


class SearchTabPagerAdapter(fm: FragmentManager) :
    FragmentStatePagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    private val fragment = ArrayList<Fragment>()

    init {
        fragment.add(SearchHotFragment())
        fragment.add(SearchRecentFragment())
    }

    override fun getItem(position: Int): Fragment {
        return fragment[position]
    }

    override fun getCount() = 2

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> Constants.SEARCH_TAB_TITLE_HOT
            1 -> Constants.SEARCH_TAB_TITLE_RECENT
            else -> null
        }
    }
}