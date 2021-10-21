package com.gongmanse.app.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.gongmanse.app.fragments.customer.FAQFragment
import com.gongmanse.app.fragments.customer.OneToOneFragment
import com.gongmanse.app.utils.Constants

class CustomerServiceTabAdapter (fm: FragmentManager) : FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT){

    companion object {
        private val TAG = CustomerServiceTabAdapter::class.java.simpleName
    }

    private val fragments = ArrayList<Fragment>()

    init {
        fragments.add(FAQFragment())
        fragments.add(OneToOneFragment())
    }

    override fun getItem(position: Int): Fragment {
        return fragments[position]
    }

    override fun getCount(): Int = fragments.size

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> Constants.CUSTOMER_TAB_TITLE_FAQ
            1 -> Constants.CUSTOMER_TAB_TITLE_ONE
            else -> null
        }
    }
}