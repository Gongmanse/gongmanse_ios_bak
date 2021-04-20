package com.gongmanse.app.feature.privacy

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentTermsOfServiceBinding
import com.gongmanse.app.utils.Constants


class TermsOfServiceFragment : Fragment() {

    private lateinit var binding: FragmentTermsOfServiceBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentTermsOfServiceBinding.inflate(inflater)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        bindUI()
    }

    private fun bindUI() {
        binding.url = Constants.WebView.WEB_TERMS_OF_SERVICE
    }

}