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
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import com.gongmanse.app.model.Current
import com.gongmanse.app.utils.Constants
import com.google.android.material.bottomsheet.BottomSheetDialogFragment


class SelectionSheetGrade(private val listener: OnBottomSheetProgressListener, var gradeTitle: String? = null) : BottomSheetDialogFragment(){

    companion object {
        private val TAG = SelectionSheetGrade::class.java.simpleName
    }

    private lateinit var binding: DialogSheetSelectionOfGradeBinding
    private lateinit var mAdapter: ProgressGradeCurrentRVAdapter
    private val linearLayoutManager = LinearLayoutManager(context)

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(
            inflater,
            R.layout.dialog_sheet_selection_of_grade,
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
        val items = listOf(
            Constants.CONTENT_VALUE_ALL_GRADE,
            Constants.CONTENT_VALUE_ELEMENTARY_first,
            Constants.CONTENT_VALUE_ELEMENTARY_second,
            Constants.CONTENT_VALUE_ELEMENTARY_third,
            Constants.CONTENT_VALUE_ELEMENTARY_fourth,
            Constants.CONTENT_VALUE_ELEMENTARY_fifth,
            Constants.CONTENT_VALUE_ELEMENTARY_sixth,
            Constants.CONTENT_VALUE_MIDDLE_first,
            Constants.CONTENT_VALUE_MIDDLE_second,
            Constants.CONTENT_VALUE_MIDDLE_third,
            Constants.CONTENT_VALUE_HIGH_first,
            Constants.CONTENT_VALUE_HIGH_second,
            Constants.CONTENT_VALUE_HIGH_third
        )

        setRVLayout()
        for (temp in items) {
            val current = Current(temp, false)
            mAdapter.addItem(current)
        }
        mAdapter.checkGrade(items)

        binding.rvGrade.apply {
            if (gradeTitle?.isNotEmpty()!!) {
                // 과목의 position get
                val position = mAdapter.getPosition(gradeTitle.toString())
                // 최상단으로 배치
                (layoutManager as LinearLayoutManager).scrollToPositionWithOffset(position, top)
                // 해당 포지션의 isCurrent = true
                mAdapter.setCurrent(position)
                Log.d(TAG, "mAdapter Position => $position")
            } else Log.e(TAG, "gradeTitle is Null")
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