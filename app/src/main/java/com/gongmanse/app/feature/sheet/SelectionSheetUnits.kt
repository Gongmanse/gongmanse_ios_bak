@file:Suppress("DEPRECATION")

package com.gongmanse.app.feature.sheet

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.gongmanse.app.R
import com.gongmanse.app.data.model.sheet.UnitsBody
import com.gongmanse.app.data.network.progress.ProgressRepository
import com.gongmanse.app.databinding.DialogSheetSelectionUnitsBinding
import com.gongmanse.app.feature.main.progress.ProgressViewModel
import com.gongmanse.app.feature.main.progress.ProgressViewModelFactory
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.listeners.OnBottomSheetToUnitListener
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import retrofit2.Retrofit

class SelectionSheetUnits(
    private val query: HashMap<String, Any?>?,
    private val listener: OnBottomSheetToUnitListener,
    private var type: Int?,
    private var selectedUnit: String = Constants.Init.INIT_STRING
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
    private lateinit var mProgressViewModel: ProgressViewModel
    private lateinit var mProgressViewModelFactory: ProgressViewModelFactory
    private val linearLayoutManager = LinearLayoutManager(context)

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
        binding.btnClose.setOnClickListener { dismiss() }
        initViewModel()
        setRVLayout()
        type?.let { itemType ->
            binding.type = itemType
            initItemList(Commons.checkSelectionSheetType(itemType))
        }
    }

    private fun initViewModel() {
        if (::mProgressViewModelFactory.isInitialized.not()) mProgressViewModelFactory = ProgressViewModelFactory(ProgressRepository())
        if (::mProgressViewModel.isInitialized.not()) mProgressViewModel = ViewModelProvider(this, mProgressViewModelFactory).get(ProgressViewModel::class.java)

        mProgressViewModel.currentUnits.observe( this, {
            mAdapter.addType(type)
            mAdapter.addItem(it as UnitsBody)
        })

    }

    private fun initItemList(itemType: Int?) {
        val itemList = itemType?.let { typeList -> resources.getStringArray(typeList) }
        // Subject, Unit 은 따로 List 형식으로 addItems
        Constants.SelectValue.apply {
            when(itemType) {
                SORT_ITEM_TYPE_UNITS   -> loadProgressUnit()
                SORT_ITEM_TYPE_SUBJECT -> {}
                else -> {
                    if (itemList != null) {
                        for (temp in itemList) {
                            val list = UnitsBody(null, temp, false)
                            type?.let { mAdapter.addType(it) }
                            mAdapter.addItem(list)
                        }
                    }
                }
            }

        }

        binding.rvUnit.apply {
            if (selectedUnit.isNotEmpty()) {
                // 과목의 position get
                val position = mAdapter.getPosition(selectedUnit.toString())
                // 최상단으로 배치
                (layoutManager as LinearLayoutManager).scrollToPositionWithOffset(position, top)
                // 해당 포지션의 isCurrent = true
                mAdapter.setCurrent(position)
            } else Log.e(TAG, "selectUnit is Null")
        }
    }

    private fun setRVLayout() {
        binding.rvUnit.apply {
            setHasFixedSize(true)
            mAdapter = SelectionSheetUnitsRVAdapter(listener)
            adapter  = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun loadProgressUnit() {
        if (query != null) {
            Constants.Extra.apply {
                mProgressViewModel.loadProgressUnit(
                    query[KEY_SUBJECT] as Int?,
                    query[KEY_GRADE] as String,
                    query[KEY_GRADE_NUM] as Int
                )
            }
        } else Log.e(TAG,"query is null")
    }
}