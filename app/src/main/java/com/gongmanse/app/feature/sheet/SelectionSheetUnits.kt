@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.sheet

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import com.gongmanse.app.R
import com.gongmanse.app.data.model.sheet.Units
import com.gongmanse.app.data.model.sheet.UnitsBody
import com.gongmanse.app.databinding.DialogSheetSelectionUnitsBinding
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.listeners.OnBottomSheetToUnitListener
import com.google.android.material.bottomsheet.BottomSheetDialogFragment

class SelectionSheetUnits(
//    private val listener: OnBottomSheetToUnitListener,
    private var type: Int?,
    selectUnit: String? = null
) : BottomSheetDialogFragment() {

    /*
    type: bottomSheet List type
    selectUnit: selected Unite Text
    *  */

    companion object {
        private val TAG = SelectionSheetUnits::class.java.simpleName
    }

    private lateinit var binding: DialogSheetSelectionUnitsBinding
    private lateinit var mAdapter: SelectionSheetUnitsRVAdapter
    private val linearLayoutManager = LinearLayoutManager(context)

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(
            inflater,
            R.layout.dialog_sheet_selection_units,
            container,
            false
        )
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        binding.btnClose.setOnClickListener { dismiss() }
        setRVLayout()
        type?.let { type -> initItemList(Commons.checkSelectionSheetType(type)) }
    }

    private fun initItemList(itemType: Int?) {
        val itemList = itemType?.let { typeList -> resources.getStringArray(typeList) }
//        val units = UnitsBody(itemList, false)
//        mAdapter.addItem(itemList)
        Log.e(TAG, "itemType => $itemList")
    }

    private fun setRVLayout() {
        binding.rvUnit.apply {
//            mAdapter = SelectionSheetUnitsRVAdapter(listener)
            adapter  = mAdapter
            linearLayoutManager.orientation = LinearLayoutManager.VERTICAL
            layoutManager = linearLayoutManager
        }
    }


}