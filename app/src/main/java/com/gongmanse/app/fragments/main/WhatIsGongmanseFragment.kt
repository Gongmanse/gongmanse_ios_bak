package com.gongmanse.app.fragments.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentWhatIsGongmanseBinding


class WhatIsGongmanseFragment : Fragment() {
    companion object {
        private val TAG = WhatIsGongmanseFragment::class.java.simpleName

        fun newInstance() = WhatIsGongmanseFragment().apply {
            arguments = bundleOf()
        }

    }

    private lateinit var binding: FragmentWhatIsGongmanseBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentWhatIsGongmanseBinding.inflate(inflater)
        return binding.root
    }
}