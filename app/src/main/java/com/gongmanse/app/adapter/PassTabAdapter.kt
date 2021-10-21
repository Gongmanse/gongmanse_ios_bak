package com.gongmanse.app.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.gongmanse.app.fragments.pass.PassHistoryFragment
import com.gongmanse.app.fragments.pass.PassStoreFragment
import com.gongmanse.app.utils.Constants

class PassTabAdapter (fm: FragmentManager): FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT){

    companion object {
        private const val TAB_CONTENT_1 = 0
    }

    override fun getItem(position: Int): Fragment {
        return when (position) {
            TAB_CONTENT_1 -> PassStoreFragment()
            else -> PassHistoryFragment()
        }
    }

    override fun getCount() = 2

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position){
            TAB_CONTENT_1 -> Constants.PASS_TAB_TITLE_STORE
            else -> Constants.PASS_TAB_TITLE_HISTORY
        }
    }
}