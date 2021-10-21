package com.gongmanse.app.fragments.sheet

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.gongmanse.app.R
import com.gongmanse.app.listeners.OnBottomSheetAlarmRepeatYearListener
import com.gongmanse.app.utils.Constants
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_repeat_year.view.*
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_repeat_year.view.btn_close


class SelectionSheetRepeatYearCounter
    (private val listener: OnBottomSheetAlarmRepeatYearListener,
     private var weekOfMonth : String,
     private var dayOfWeek : String,
     private var dayOfMonth : String,
     private var monthOfYear : String
): BottomSheetDialogFragment() {

    private lateinit var mContext: View
    private var selectedValueMonthDay =""
    private var selectedValueMonthWeekDay =""

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        mContext = inflater.inflate(R.layout.dialog_sheet_selection_of_repeat_year, container, false)
        return mContext
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        setCheck()
        mContext.rootView.btn_close.setOnClickListener { dismiss() }
        mContext.btn_month_day.setOnClickListener {
            Log.d("클릭이벤트","클릭이벤트")
            updateSelection(Constants.MONTH_DAY,selectedValueMonthDay)
        }
        mContext.btn_month_week_of_day.setOnClickListener {
            Log.d("클릭이벤트","클릭이벤트")
            updateSelection(Constants.MONTH_WEEK_OF_DAY,selectedValueMonthWeekDay)
        }
    }

    private fun updateSelection(index : Int, value: String) {
        listener.selectionRepeatYear(index,value)
        dismiss()
    }

    @SuppressLint("SetTextI18n")
    private fun setCheck(){
        Log.d("setCheck","$monthOfYear 월 $dayOfMonth ")
        Log.d("setCheck","$weekOfMonth 째주 $dayOfWeek 요일 ")

        mContext.tv_month_day.text =" $monthOfYear 월 $dayOfMonth 일 "
        mContext.tv_month_week_of_day.text = " $monthOfYear 월 ${weekOfMonth}째주 $dayOfWeek 요일 "
        selectedValueMonthDay = "매년 $monthOfYear 월 $dayOfMonth 일 "
        selectedValueMonthWeekDay = "매년 $monthOfYear 월 ${weekOfMonth}째주 $dayOfWeek 요일 "

    }

}