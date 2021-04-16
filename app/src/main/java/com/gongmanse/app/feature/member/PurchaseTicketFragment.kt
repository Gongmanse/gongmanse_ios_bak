package com.gongmanse.app.feature.member

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.gongmanse.app.databinding.FragmentPurchaseTicketBinding


class PurchaseTicketFragment : Fragment() {

    private lateinit var binding: FragmentPurchaseTicketBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentPurchaseTicketBinding.inflate(inflater)
        return binding.root
    }

    companion object {
        private val TAG = PurchaseTicketFragment::class.java.simpleName
    }

}