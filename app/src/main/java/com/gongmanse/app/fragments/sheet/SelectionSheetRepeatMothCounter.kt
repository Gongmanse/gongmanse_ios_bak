package com.gongmanse.app.fragments.sheet

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.R
import com.gongmanse.app.listeners.OnBottomSheetAlarmRepeatMonthListener
import com.gongmanse.app.utils.Constants
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_repeat_month.view.*



class SelectionSheetRepeatMothCounter
    (private val listener: OnBottomSheetAlarmRepeatMonthListener,
     private var weekOfMonth : String,
     private var dayOfWeek : String,
     private var dayOfMonth : String
): BottomSheetDialogFragment() {

    private lateinit var mContext: View
    private var selectedValueDayOfMonth =""
    private var selectedValueWeekOfMonth =""

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        mContext = inflater.inflate(R.layout.dialog_sheet_selection_of_repeat_month, container, false)
        return mContext
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        setCheck()
        mContext.rootView.btn_close.setOnClickListener { dismiss() }
        mContext.btn_day_of_month.setOnClickListener {
            Log.d("클릭이벤트","클릭이벤트")
            updateSelection(Constants.DAY_OF_MONTH,selectedValueDayOfMonth)
        }
        mContext.btn_week_of_month.setOnClickListener {
            Log.d("클릭이벤트","클릭이벤트")
            updateSelection(Constants.WEEK_OF_MONTH,selectedValueWeekOfMonth)
        }
    }

    private fun updateSelection(index : Int,value:String) {
        listener.selectionRepeatMonth(index,value)
        dismiss()
    }

    @SuppressLint("SetTextI18n")
    private fun setCheck(){
        Log.d("setCheck","매월 $dayOfMonth ")
        Log.d("setCheck","$weekOfMonth 째주 $dayOfWeek 요일 ")

        mContext.tv_day_of_month.text ="매월 $dayOfMonth 일 "
        mContext.tv_week_of_month.text = "${weekOfMonth}째주 $dayOfWeek 요일 "
        selectedValueDayOfMonth = "매월 $dayOfMonth 일 "
        selectedValueWeekOfMonth = "매월 ${weekOfMonth}째주 $dayOfWeek 요일 "
    }

}