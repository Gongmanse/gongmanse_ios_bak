package com.gongmanse.app.fragments

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.R
import com.gongmanse.app.adapter.progress.ProgressGradeRVAdapter
import com.gongmanse.app.databinding.DialogSheetSelectionOfGradeBinding
import com.gongmanse.app.databinding.DialogSheetSelectionSettingBinding
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import java.util.*


class SelectionSheetSetting(private val listener: OnBottomSheetProgressListener,private var selectText : String) : BottomSheetDialogFragment() {

    companion object {
        private val TAG = SelectionSheetSetting::class.java.simpleName
    }

    private lateinit var binding: DialogSheetSelectionSettingBinding
    private lateinit var mAdapter: ProgressGradeRVAdapter
    private val linearLayoutManager = LinearLayoutManager(context)

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = DataBindingUtil.inflate(
            inflater,
            R.layout.dialog_sheet_selection_setting,
            container,
            false
        )
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        Log.d(TAG, "onActivityCreated()")
        initView()
    }

    private fun initView() {
        Log.d(TAG, "initView()")
        binding.btnClose.setOnClickListener { dismiss() }
        Log.e(TAG, "ItemGrade selectText => $selectText")
        val gradeArray = resources.getStringArray(R.array.grade)
        val itemGrade = ArrayList<String>()
        for (temp : String in gradeArray){
            itemGrade.add(temp)
        }
        val subjectArray = resources.getStringArray(R.array.subject)
        val itemSubject = ArrayList<String>()
        for (temp : String in subjectArray){
            itemSubject.add(temp)
        }
        if(itemGrade.contains(selectText)){
            Log.d(TAG, "itemGrade()")
            setRVLayout()
            mAdapter.addItems(itemGrade)
            mAdapter.checkGrade(itemGrade)
        }else{
            Log.d(TAG, "itemSubject()")
            setRVLayout()
            mAdapter.addItems(itemSubject)
//            mAdapter.checkSubject(itemSubject)
        }
    }

    private fun setRVLayout() {
        Log.d(TAG, "setRVLayout()")
        binding.rvGrade.apply {
            mAdapter = ProgressGradeRVAdapter(listener)
            adapter = mAdapter
            linearLayoutManager.orientation = LinearLayoutManager.VERTICAL
            layoutManager = linearLayoutManager
        }
    }
}