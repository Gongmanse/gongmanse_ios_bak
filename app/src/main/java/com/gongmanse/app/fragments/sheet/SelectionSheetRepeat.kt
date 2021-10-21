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
import kotlinx.android.synthetic.main.dialog_sheet_selection.view.btn_close
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_repeat.view.*


class SelectionSheetRepeat(private val listener: OnBottomSheetAlarmRepeatListener, private var selectText : String): BottomSheetDialogFragment() {

    private lateinit var mContext: View
    private val repeatArray = arrayListOf<String>()


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        mContext = inflater.inflate(R.layout.dialog_sheet_selection_of_repeat, container, false)
        return mContext
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)


        getStringArray()
        setCheck()
        mContext.rootView.btn_close.setOnClickListener { dismiss() }
        mContext.rootView.btn_empty.setOnClickListener {updateSelection(repeatArray[0])}
        mContext.rootView.btn_day.setOnClickListener {updateSelection(repeatArray[1])}
        mContext.rootView.btn_week.setOnClickListener {updateSelection(repeatArray[2])}
        mContext.rootView.btn_month.setOnClickListener {updateSelection(repeatArray[3])}
        mContext.rootView.btn_year.setOnClickListener {updateSelection(repeatArray[4])}

    }

    private fun getStringArray(){
        val arr =  resources.getStringArray(R.array.repeat)
        for(i in arr){
            repeatArray.add(i)
        }
    }

    private fun updateSelection(string: String) {
        listener.selectionRepeat(string)
        dismiss()
    }

    @SuppressLint("ResourceAsColor")
    private fun setCheck(){
        when(selectText){
            repeatArray[0] -> {
                mContext.rootView.iv_empty.visibility = View.VISIBLE
                selectText =  repeatArray[0]
                mContext.rootView.tv_empty.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            repeatArray[1] ->{
                mContext.iv_day.visibility = View.VISIBLE
                selectText =  repeatArray[1]
                mContext.tv_day.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            repeatArray[2] ->{
                mContext.iv_week.visibility = View.VISIBLE
                selectText =  repeatArray[2]
                mContext.rootView.tv_week.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            repeatArray[3] -> {
                mContext.iv_month.visibility = View.VISIBLE
                selectText =  repeatArray[3]
                mContext.rootView.tv_month.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            repeatArray[4] -> {
                mContext.iv_year.visibility = View.VISIBLE
                selectText =  repeatArray[4]
                mContext.rootView.tv_year.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
        }
    }

}