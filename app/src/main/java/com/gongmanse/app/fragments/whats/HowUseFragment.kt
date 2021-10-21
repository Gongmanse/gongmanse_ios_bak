package com.gongmanse.app.fragments.whats

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.databinding.FragmentHowUseBinding

class HowUseFragment : Fragment() {

    companion object {
        private val TAG = HowUseFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentHowUseBinding

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        // Inflate the layout for this fragment
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_how_use, container, false)
        return binding.root
    }

    fun scrollToTop() = binding.svHowUse.smoothScrollTo(0, 0)

}