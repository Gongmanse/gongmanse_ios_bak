package com.gongmanse.app.fragments.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentNoticeBinding


class NoticeFragment : Fragment() {
    companion object {
        private val TAG = NoticeFragment::class.java.simpleName

        fun newInstance() = NoticeFragment().apply {
            arguments = bundleOf()
        }

    }

    private lateinit var binding: FragmentNoticeBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentNoticeBinding.inflate(inflater)
        return binding.root
    }
}