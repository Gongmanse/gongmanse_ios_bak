@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.sheet

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.databinding.DialogSheetSelectionUnitsBinding

class SelectionSheetUnits : Fragment() {

    companion object {
        private val TAG = SelectionSheetUnits::class.java.simpleName
    }

    private lateinit var binding: DialogSheetSelectionUnitsBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.dialog_sheet_selection_units, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {

    }
}