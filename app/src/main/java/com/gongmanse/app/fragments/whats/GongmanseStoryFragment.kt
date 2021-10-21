package com.gongmanse.app.fragments.whats

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.adapter.bindViewSettingInfoGrade
import com.gongmanse.app.databinding.FragmentGongmanseStoryBinding


class GongmanseStoryFragment : Fragment() {

    private lateinit var binding: FragmentGongmanseStoryBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_gongmanse_story, container, false)
        return binding.root
    }

    fun scrollToTop() = binding.svStory.smoothScrollTo(0, 0)

}