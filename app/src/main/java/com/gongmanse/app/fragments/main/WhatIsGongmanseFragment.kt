package com.gongmanse.app.fragments.main

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import com.gongmanse.app.R
import com.gongmanse.app.databinding.FragmentMyScheduleBinding


class WhatIsGongmanseFragment : Fragment() {
    companion object {
        private val TAG = WhatIsGongmanseFragment::class.java.simpleName

        fun newInstance() = WhatIsGongmanseFragment().apply {
            arguments = bundleOf()
        }

    }

    private lateinit var binding: FragmentMyScheduleBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMyScheduleBinding.inflate(inflater)
        return binding.root
    }
}