package com.gongmanse.app.feature.main

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import com.gongmanse.app.R
import com.gongmanse.app.databinding.FragmentEmptyBinding
import com.gongmanse.app.databinding.FragmentMyNotificationBinding
import com.gongmanse.app.feature.notification.MyNotificationFragment


class EmptyFragment : Fragment() {
    companion object {
        private val TAG = EmptyFragment::class.java.simpleName

        fun newInstance() = EmptyFragment().apply {
            arguments = bundleOf()
        }

    }

    private lateinit var binding: FragmentEmptyBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentEmptyBinding.inflate(inflater)
        return binding.root
    }

}