package com.gongmanse.app.feature.active

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentMyNoteBinding


class MyNoteFragment : Fragment() {

    private lateinit var binding: FragmentMyNoteBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMyNoteBinding.inflate(inflater)
        return binding.root
    }

    companion object {
        private val TAG = MyNoteFragment::class.java.simpleName
    }

}