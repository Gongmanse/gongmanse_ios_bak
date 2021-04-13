package com.gongmanse.app.fragments.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentCustomerServiceBinding


class CustomerServiceFragment : Fragment() {
    companion object {
        private val TAG = CustomerServiceFragment::class.java.simpleName

        fun newInstance() = CustomerServiceFragment().apply {
            arguments = bundleOf()
        }

    }

    private lateinit var binding: FragmentCustomerServiceBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentCustomerServiceBinding.inflate(inflater)
        return binding.root
    }
}