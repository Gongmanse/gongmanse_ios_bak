package com.gongmanse.app.adapter.active

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.gongmanse.app.fragments.active.*
import com.gongmanse.app.utils.Constants

class MyActiveTabAdapter (fm: FragmentManager): FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT){

    companion object {
        private const val TAB_CONTENT_1 = 0
        private const val TAB_CONTENT_2 = 1
        private const val TAB_CONTENT_3 = 2
        private const val TAB_CONTENT_4 = 3
    }

    private var recentVideoFragment: ActiveRecentVideoFragment = ActiveRecentVideoFragment()
    private var noteFragment: ActiveNoteFragment = ActiveNoteFragment()
    private var qnaFragment: ActiveQNAFragment = ActiveQNAFragment()
    private var questionFragment: ActiveQuestionFragment = ActiveQuestionFragment()
    private var favoritesFragment: ActiveFavoritesFragment = ActiveFavoritesFragment()

    override fun getItem(position: Int): Fragment {
        return when (position) {
            TAB_CONTENT_1 -> recentVideoFragment
            TAB_CONTENT_2 -> noteFragment
            TAB_CONTENT_3 -> qnaFragment
            TAB_CONTENT_4 -> questionFragment
            else -> favoritesFragment
        }
    }

    override fun getCount() = 5

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position){
            TAB_CONTENT_1 -> Constants.ACTIVE_TAB_TITLE_RECENT_VIDEO
            TAB_CONTENT_2 -> Constants.ACTIVE_TAB_TITLE_NOTE
            TAB_CONTENT_3 -> Constants.ACTIVE_TAB_TITLE_QNA
            TAB_CONTENT_4 -> Constants.ACTIVE_TAB_TITLE_QUESTION
            else -> Constants.ACTIVE_TAB_TITLE_FAVORITES
        }
    }

}