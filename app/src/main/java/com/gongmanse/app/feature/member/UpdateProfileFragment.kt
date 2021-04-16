package com.gongmanse.app.feature.member

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentUpdateProfileBinding


class UpdateProfileFragment : Fragment() {

    private lateinit var binding: FragmentUpdateProfileBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentUpdateProfileBinding.inflate(inflater)
        return binding.root
    }

    companion object {
        private val TAG = UpdateProfileFragment::class.java.simpleName
    }

}