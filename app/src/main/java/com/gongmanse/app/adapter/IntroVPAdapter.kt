package com.gongmanse.app.adapter

import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.gongmanse.app.fragments.IntroFragment
import com.gongmanse.app.utils.Constants

class IntroVPAdapter(fm: FragmentManager, lifecycle: Lifecycle): FragmentStateAdapter(fm, lifecycle) {

    override fun getItemCount(): Int {
        return 8
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun createFragment(position: Int): Fragment {
        val fragment = IntroFragment()
        fragment.arguments = Bundle().apply {
            putInt(Constants.INTRO_POSITION, position)
        }
        return fragment
    }
}