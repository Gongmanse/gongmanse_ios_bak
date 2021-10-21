package com.gongmanse.app.fragments.sheet

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TimePicker
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.R
import com.gongmanse.app.activities.MainActivity
import com.gongmanse.app.activities.ScheduleAddActivity
import com.gongmanse.app.listeners.OnBottomSheetSelectTimeListener
import kotlinx.android.synthetic.main.activity_schedule_add.*
import kotlinx.android.synthetic.main.dialog_sheet_selection.view.btn_close
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_date.view.tv_select_date
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_time.view.*
import org.jetbrains.anko.timePicker


class SelectionSheetTime(private val listener: OnBottomSheetSelectTimeListener,private val type: Int,private val date : String): BottomSheetDialogFragment() {

    private lateinit var mContext: View
    private lateinit var mTimePicker : TimePicker


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        mContext = inflater.inflate(R.layout.dialog_sheet_selection_of_time, container, false)
        return mContext
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        mContext.rootView.btn_close.setOnClickListener { dismiss() }
        initView()
    }
    fun initView(){

        mTimePicker = mContext.time_picker


        mContext.rootView.tv_select_time.setOnClickListener {
            val hour = mTimePicker.hour
            val minute = mTimePicker.minute
            updateSelection("${String.format("%02d",hour)}:${String.format("%02d",minute)}" ,type)
        }

        mContext.rootView.tv_back.setOnClickListener {
            listener.selectionBack(date ,type)
            dismiss()
        }
    }

    private fun updateSelection(string: String, type: Int) {
        listener.selectionTime(string,type)
        dismiss()
    }

}
