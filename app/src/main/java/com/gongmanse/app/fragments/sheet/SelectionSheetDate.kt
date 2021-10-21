package com.gongmanse.app.fragments.sheet

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.DatePicker
import android.widget.DatePicker.OnDateChangedListener
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.R
import com.gongmanse.app.listeners.OnBottomSheetSelectDateListener
import kotlinx.android.synthetic.main.dialog_sheet_selection.view.btn_close
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_date.view.*
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_time.view.*
import java.text.SimpleDateFormat
import java.util.*


class SelectionSheetDate(private val listener: OnBottomSheetSelectDateListener,private val setDate : String,private val type : Int): BottomSheetDialogFragment() {

    private lateinit var mContext: View
    private lateinit var mDatePicker : DatePicker




    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        mContext = inflater.inflate(R.layout.dialog_sheet_selection_of_date, container, false)
        return mContext
    }



    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        mContext.rootView.btn_close.setOnClickListener { dismiss() }
        initView()
    }
    @SuppressLint("SimpleDateFormat")
    fun initView(){

        val year = setDate.substring(0,4).toInt()
        val month = setDate.substring(5,7).toInt()-1 // 날짜가 month +1 된 상태로 인식되어서 미리 빼줘야함
        val date = setDate.substring(8,10).toInt()

        Log.e("date"," $year : $month : $date ")
        mDatePicker = mContext.date_picker
        mDatePicker.init(year,month,date
        ) { view, _, monthOfYear, dayOfMonth -> }


        val now = Date()
        val format1 = SimpleDateFormat("yyyy-MM-dd", Locale.KOREA)
        val stringTime = format1.format(now)
        val tYear = stringTime.substring(0,4).toInt()
        val tMonth = stringTime.substring(5,7).toInt()
        val tDate = stringTime.substring(8,10).toInt()

        mContext.rootView.tv_select_date.setOnClickListener {
            val year = mDatePicker.year.toString()
            val month = mDatePicker.month + 1   //달력은 무조건 +1 해야함(month 만)
            val date = mDatePicker.dayOfMonth
            updateSelection("$year-${String.format("%02d",month)}-${String.format("%02d",date)}" , type)
        }

        mContext.rootView.tv_today.setOnClickListener {
            mDatePicker.init(tYear,tMonth,tDate
            ) { view, year, monthOfYear, dayOfMonth -> }
        }
    }

    private fun updateSelection(string: String , type: Int) {
        listener.selectionDate(string,type)
        dismiss()
    }

}
