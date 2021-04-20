package com.gongmanse.app.feature.active

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.gongmanse.app.MainActivity
import com.gongmanse.app.databinding.FragmentMyActivityBinding
import com.gongmanse.app.databinding.FragmentSettingsBinding
import com.google.android.material.tabs.TabLayout


class MyActivityFragment : Fragment() {

    private lateinit var binding: FragmentMyActivityBinding
    private lateinit var mMyTabAdapter: MyActivityTabAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMyActivityBinding.inflate(inflater)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        bindUI()
    }

    private fun bindUI() {
        mMyTabAdapter = MyActivityTabAdapter((context as MainActivity).supportFragmentManager)
        binding.tabLayout.addOnTabSelectedListener(onTabSelectedListener)
        binding.viewPager.apply {
            adapter = mMyTabAdapter
            offscreenPageLimit = mMyTabAdapter.count
            binding.tabLayout.setupWithViewPager(this)
        }
    }

    private val onTabSelectedListener = object: TabLayout.OnTabSelectedListener {
        override fun onTabUnselected(tab: TabLayout.Tab?) {

        }
        override fun onTabReselected(tab: TabLayout.Tab?) {

        }
        override fun onTabSelected(tab: TabLayout.Tab?) {

        }
    }

    companion object {
        private val TAG = MyActivityFragment::class.java.simpleName
    }

}