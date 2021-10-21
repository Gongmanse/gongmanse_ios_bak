package com.gongmanse.app.fragments.sheet

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import com.gongmanse.app.R
import com.gongmanse.app.adapter.progress.ProgressGradeCurrentRVAdapter
import com.gongmanse.app.databinding.DialogSheetSelectionOfGradeBinding
import com.gongmanse.app.databinding.DialogSheetSelectionOfSearchGradeBinding
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import com.gongmanse.app.model.Current
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import java.util.*


class SelectionSheetSearchGrade(private val listener: OnBottomSheetProgressListener, var gradeTitle: String? = null) :
    BottomSheetDialogFragment() {

    companion object {
        private val TAG = SelectionSheetSearchGrade::class.java.simpleName
    }

    private lateinit var binding: DialogSheetSelectionOfSearchGradeBinding
    private lateinit var mAdapter: ProgressGradeCurrentRVAdapter
    private val linearLayoutManager = LinearLayoutManager(context)

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = DataBindingUtil.inflate(
            inflater,
            R.layout.dialog_sheet_selection_of_search_grade,
            container,
            false
        )
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        Log.d(TAG, "initView()")
        setRVLayout()
        binding.btnClose.setOnClickListener { dismiss() }

        // 모든 학년, 초, 중, 고등
        val gradeArray = resources.getStringArray(R.array.grade)
        val itemGrade = ArrayList<String>()

        for (temp : String in gradeArray) itemGrade.add(temp)

        for (temp in itemGrade){
            val current = Current(temp, false)
            mAdapter.addItem(current)
        }
        mAdapter.checkGrade(itemGrade)

        binding.rvGrade.apply {
            Log.e(TAG, "gradeTitle => $gradeTitle")
            if (gradeTitle.isNullOrEmpty()) {
                Log.e(TAG, "gradeTitle is Null")
            } else {
                val position = mAdapter.getPosition(gradeTitle.toString())
                (layoutManager as LinearLayoutManager).scrollToPositionWithOffset(position, top)
                mAdapter.setCurrent(position)
                Log.d(TAG,"mAdapter Position => $position")
            }
        }
    }

    private fun setRVLayout() {
        Log.d(TAG, "setRVLayout()")
        binding.rvGrade.apply {
            mAdapter = ProgressGradeCurrentRVAdapter(listener)
            adapter = mAdapter
            linearLayoutManager.orientation = LinearLayoutManager.VERTICAL
            layoutManager = linearLayoutManager
        }
    }
}