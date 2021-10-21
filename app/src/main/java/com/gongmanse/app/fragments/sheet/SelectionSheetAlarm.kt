package com.gongmanse.app.fragments.sheet

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.R
import com.gongmanse.app.listeners.OnBottomSheetAlarmRepeatListener
import com.gongmanse.app.listeners.OnBottomSheetListener
import com.gongmanse.app.model.KEMSelectionModel
import com.gongmanse.app.utils.Constants
import kotlinx.android.synthetic.main.dialog_sheet_selection.view.*
import kotlinx.android.synthetic.main.dialog_sheet_selection.view.btn_close
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_alarm.view.*


class SelectionSheetAlarm(private val listener: OnBottomSheetAlarmRepeatListener, private var selectText : String): BottomSheetDialogFragment() {
    
    private lateinit var mContext: View
    private val alarmArray = arrayListOf<String>()


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        mContext = inflater.inflate(R.layout.dialog_sheet_selection_of_alarm, container, false)
        return mContext
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)


        getStringArray()
        setCheck()
        mContext.rootView.btn_close.setOnClickListener { dismiss() }
        mContext.rootView.btn_empty.setOnClickListener {updateSelection(alarmArray[0])}
        mContext.rootView.btn_on_time.setOnClickListener {updateSelection(alarmArray[1])}
        mContext.rootView.btn_before_ten.setOnClickListener {updateSelection(alarmArray[2])}
        mContext.rootView.btn_before_thirty.setOnClickListener {updateSelection(alarmArray[3])}
        mContext.rootView.btn_before_hour.setOnClickListener {updateSelection(alarmArray[4])}
        mContext.rootView.btn_before_three_hour.setOnClickListener {updateSelection(alarmArray[5])}
        mContext.rootView.btn_before_twelve_hour.setOnClickListener {updateSelection(alarmArray[6])}
        mContext.rootView.btn_before_day.setOnClickListener {updateSelection(alarmArray[7])}
        mContext.rootView.btn_before_week.setOnClickListener {updateSelection(alarmArray[8])}

    }

    private fun getStringArray(){
        val arr =  resources.getStringArray(R.array.alarm)
        for(i in arr){
            alarmArray.add(i)
        }
    }

    private fun updateSelection(string: String) {
        listener.selectionAlarm(string)
        dismiss()
    }

    @SuppressLint("ResourceAsColor")
    private fun setCheck(){
        when(selectText){
            alarmArray[0] -> {
                mContext.rootView.iv_empty.visibility = View.VISIBLE
                selectText =  alarmArray[0]
                mContext.rootView.tv_empty.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            alarmArray[1] ->{
                mContext.iv_on_time.visibility = View.VISIBLE
                selectText =  alarmArray[1]
                mContext.tv_on_time.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            alarmArray[2] ->{
                mContext.iv_before_ten.visibility = View.VISIBLE
                selectText =  alarmArray[2]
                mContext.rootView.tv_before_ten.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            alarmArray[3] -> {
                mContext.iv_before_thirty.visibility = View.VISIBLE
                selectText =  alarmArray[3]
                mContext.rootView.tv_before_thirty.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            alarmArray[4] -> {
                mContext.iv_before_hour.visibility = View.VISIBLE
                selectText =  alarmArray[4]
                mContext.rootView.tv_before_hour.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            alarmArray[5] -> {
                mContext.iv_before_three_hour.visibility = View.VISIBLE
                selectText =  alarmArray[5]
                mContext.rootView.tv_before_three_hour.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            alarmArray[6] ->{
                mContext.iv_before_twelve_hour.visibility = View.VISIBLE
                selectText =  alarmArray[6]
                mContext.rootView.tv_before_twelve_hour.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            alarmArray[7] ->{
                mContext.iv_before_day.visibility = View.VISIBLE
                selectText =  alarmArray[7]
                mContext.rootView.tv_before_day.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            alarmArray[8] ->{
                mContext.iv_before_week.visibility = View.VISIBLE
                selectText =  alarmArray[8]
                mContext.rootView.tv_before_week.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
        }
    }

}