package com.gongmanse.app.fragments.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentMyNotificationBinding

class MyNotificationFragment : Fragment() {

    companion object {
        private val TAG = MyNotificationFragment::class.java.simpleName

        fun newInstance() = MyNotificationFragment().apply {
            arguments = bundleOf()
        }

    }

    private lateinit var binding: FragmentMyNotificationBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMyNotificationBinding.inflate(inflater)
        return binding.root
    }

}