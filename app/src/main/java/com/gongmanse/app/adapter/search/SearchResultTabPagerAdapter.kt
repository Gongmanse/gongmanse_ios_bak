package com.gongmanse.app.adapter.search

import android.util.Log
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentStatePagerAdapter
import com.gongmanse.app.fragments.search.SearchCounselFragment
import com.gongmanse.app.fragments.search.SearchNoteFragment
import com.gongmanse.app.fragments.search.SearchVideoFragment
import com.gongmanse.app.utils.Constants
import org.koin.core.logger.KOIN_TAG

class SearchResultTabPagerAdapter(
    fm: FragmentManager,
    grade: String?,
    subjectId: Int?,
    keyword: String?,
    from: Boolean
) :
    FragmentStatePagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {

    companion object {
        private val TAG = SearchResultTabPagerAdapter::class.java.simpleName
    }

    private val fragments = ArrayList<Fragment>()

    init {
        Log.i(TAG, "grade:$grade\n subjectId:$subjectId\n keyword:$keyword\n from:$from\n")
        fragments.add(SearchVideoFragment(grade, subjectId, keyword, from))
        fragments.add(SearchCounselFragment(keyword, from))
        fragments.add(SearchNoteFragment(grade,subjectId, keyword))
    }

    override fun getItem(position: Int): Fragment {
        return fragments[position]
    }

    override fun getCount() = fragments.size

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> Constants.SEARCH_TAB_TITLE_VIDEO
            1 -> Constants.SEARCH_TAB_TITLE_COUNSEL
            2 -> Constants.SEARCH_TAB_TITLE_NOTE
            else -> null
        }
    }
}