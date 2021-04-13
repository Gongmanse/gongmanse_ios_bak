package com.gongmanse.app.feature.main.home.tabs

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.R
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.listeners.OnBottomSheetListener
import kotlinx.android.synthetic.main.dialog_sheet_selection.view.*

@Suppress("DEPRECATION")
class SelectionSheet(private val listener: OnBottomSheetListener, private var selectText : String): BottomSheetDialogFragment() {

    private lateinit var mContext: View


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        mContext = inflater.inflate(R.layout.dialog_sheet_selection, container, false)
        return mContext
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        setCheck()
        mContext.rootView.btn_close.setOnClickListener { dismiss() }
        mContext.rootView.btn_show_all.setOnClickListener {updateSelection(Constants.CONTENT_VALUE_ALL)}
        mContext.rootView.btn_show_series.setOnClickListener {updateSelection(Constants.CONTENT_VALUE_SERIES)}
        mContext.rootView.btn_show_problem.setOnClickListener {updateSelection(Constants.CONTENT_VALUE_PROBLEM)}
        mContext.rootView.btn_show_note.setOnClickListener {updateSelection(Constants.CONTENT_VALUE_NOTE)}

    }

    private fun updateSelection(string: String) {
        listener.selection(string)
        dismiss()
    }

    @SuppressLint("ResourceAsColor")
    private fun setCheck(){
        when(selectText){
            Constants.CONTENT_VALUE_ALL -> {
                mContext.rootView.iv_show_all.visibility = View.VISIBLE
                selectText = Constants.CONTENT_VALUE_ALL
                mContext.rootView.tv_show_all.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            Constants.CONTENT_VALUE_SERIES ->{
                mContext.iv_show_series.visibility = View.VISIBLE
                selectText = Constants.CONTENT_VALUE_SERIES
                mContext.tv_show_series.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            Constants.CONTENT_VALUE_PROBLEM ->{
                mContext.iv_show_problem.visibility = View.VISIBLE
                selectText = Constants.CONTENT_VALUE_PROBLEM
                mContext.rootView.tv_show_problem.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            Constants.CONTENT_VALUE_NOTE -> {
                mContext.iv_show_note.visibility = View.VISIBLE
                selectText = Constants.CONTENT_VALUE_NOTE
                mContext.rootView.tv_show_note.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
        }
    }

}