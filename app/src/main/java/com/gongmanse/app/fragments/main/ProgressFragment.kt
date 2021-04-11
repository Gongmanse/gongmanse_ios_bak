package com.gongmanse.app.fragments.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentProgressBinding


class ProgressFragment : Fragment() {

    companion object {
        private val TAG = ProgressFragment::class.java.simpleName

        fun newInstance() = ProgressFragment().apply {
            arguments = bundleOf()
        }

    }

    private lateinit var binding: FragmentProgressBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentProgressBinding.inflate(inflater)
        return binding.root
    }

}