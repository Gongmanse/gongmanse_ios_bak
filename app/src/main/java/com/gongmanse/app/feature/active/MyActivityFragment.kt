package com.gongmanse.app.feature.active

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentMyActivityBinding


class MyActivityFragment : Fragment() {

    private lateinit var binding: FragmentMyActivityBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMyActivityBinding.inflate(inflater)
        return binding.root
    }

    companion object {
        private val TAG = MyActivityFragment::class.java.simpleName
    }

}