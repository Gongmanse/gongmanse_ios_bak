@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.sheet

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.databinding.DialogSheetSelectionUnitsBinding
import com.gongmanse.app.utils.Commons
import com.google.android.material.bottomsheet.BottomSheetDialogFragment

class SelectionSheetUnits(private var type: Int?, selectUnit: String? = null) : BottomSheetDialogFragment() {

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
        type?.let { type -> initItemList(Commons.checkSelectionSheetType(type)) }
    }

    private fun initItemList(itemType: Int?) {
        val itemList = itemType?.let { typeList -> resources.getStringArray(typeList) }
        Log.e(TAG, "itemType => $itemList")
    }
}