package com.gongmanse.app.fragments.sheet

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.NumberPicker
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.R
import com.gongmanse.app.listeners.OnBottomSheetAlarmRepeatDayListener
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_repeat_day.view.btn_close
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_repeat_day.view.*
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_repeat_day.view.tv_back
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_repeat_day.view.tv_select_time


class SelectionSheetRepeatDayCounter(private val listener: OnBottomSheetAlarmRepeatDayListener, private var selectText : String): BottomSheetDialogFragment() {


    private lateinit var mContext: View
    private lateinit var mNumberPicker : NumberPicker


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        mContext = inflater.inflate(R.layout.dialog_sheet_selection_of_repeat_day, container, false)
        return mContext
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        mContext.rootView.btn_close.setOnClickListener { dismiss() }
        initView()
    }
    fun initView(){

        mNumberPicker = mContext.numberPicker
        mNumberPicker.minValue = 1
        mNumberPicker.maxValue = 365
        mNumberPicker.wrapSelectorWheel = false

        mContext.rootView.tv_back.setOnClickListener {
            listener.selectionRepeatBack(selectText)
            dismiss()
        }
        mContext.rootView.tv_select_time.setOnClickListener {
            val value = mNumberPicker.value.toString()
            updateSelection(value)
            dismiss()
        }
    }

    private fun updateSelection(value: String) {
        listener.selectionRepeatDay(selectText , value )
        dismiss()
    }

}