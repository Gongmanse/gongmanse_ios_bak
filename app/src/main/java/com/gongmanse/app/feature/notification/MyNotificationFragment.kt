package com.gongmanse.app.feature.notification

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentMyNotificationBinding

class MyNotificationFragment : Fragment() {

    private lateinit var binding: FragmentMyNotificationBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMyNotificationBinding.inflate(inflater)
        return binding.root
    }

    companion object {
        private val TAG = MyNotificationFragment::class.java.simpleName
    }

}