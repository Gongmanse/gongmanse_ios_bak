package com.gongmanse.app.feature.active

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentMyRecentVideoBinding


class MyRecentVideoFragment : Fragment() {

    private lateinit var binding: FragmentMyRecentVideoBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMyRecentVideoBinding.inflate(inflater)
        return binding.root
    }

    companion object {
        private val TAG = MyRecentVideoFragment::class.java.simpleName
    }

}