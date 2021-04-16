package com.gongmanse.app.feature.schedule

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentMyScheduleBinding


class MyScheduleFragment : Fragment() {

    private lateinit var binding: FragmentMyScheduleBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMyScheduleBinding.inflate(inflater)
        return binding.root
    }

    companion object {
        private val TAG = MyScheduleFragment::class.java.simpleName
    }

}