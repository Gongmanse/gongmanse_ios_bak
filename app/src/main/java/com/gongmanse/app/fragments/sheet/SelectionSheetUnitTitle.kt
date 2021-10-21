package com.gongmanse.app.fragments.sheet

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.progress.ProgressUnitRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.DialogSheetSelectionOfUnitBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import com.gongmanse.app.model.Progress
import com.gongmanse.app.model.ProgressData
import com.gongmanse.app.utils.Constants
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class SelectionSheetUnitTitle(
    private val listener: OnBottomSheetProgressListener,
    private var subject: Int?,
    private var grade: String?,
    private var jindoTitle: String?,
    private var gradeNum: Int?
) :
    BottomSheetDialogFragment() {

    companion object {
        private val TAG = SelectionSheetUnitTitle::class.java.simpleName
    }

    private lateinit var binding: DialogSheetSelectionOfUnitBinding
    private lateinit var mAdapter: ProgressUnitRVAdapter
    private val linearLayoutManager = LinearLayoutManager(context)
    private val limit: Int = 50

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.dialog_sheet_selection_of_unit, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        Log.d(TAG, "onActivityCreated ")
        initView()
    }

    private fun initView() {
        Log.d(TAG, "initView()")
        binding.btnClose.setOnClickListener { dismiss() }
        initRVLayout()
        loadProgressUnit()
    }

    private fun initRVLayout() {
        Log.d(TAG, "initRVLayout")
        val items = ObservableArrayList<ProgressData>()
        items.add(0, ProgressData(Constants.VIEW_TYPE_ITEM,null, Constants.CONTENT_VALUE_ALL_UNIT, null, null, null, null, null, null, null))
        Log.d(TAG, "Items => $items")
        mAdapter = ProgressUnitRVAdapter(listener).apply {
            Log.d(TAG, "initRVLayout ::")
            addItems(items)
        }
        binding.rvUnit.apply {
            Log.d(TAG, "RV_UNIT ::")
            adapter = mAdapter
            layoutManager = linearLayoutManager
            addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL))
        }
    }

    private fun loadProgressUnit() {
        RetrofitClient.getService()
            .getJindoTitle(subject, grade, gradeNum, Constants.OFFSET_DEFAULT, limit)
            .enqueue(object : Callback<Progress> {
                override fun onFailure(call: Call<Progress>, t: Throwable) {
                    Log.e(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(call: Call<Progress>, response: Response<Progress>) {
                    if (!response.isSuccessful) Log.e(
                        TAG,
                        "Failed API code : ${response.code()}\n message : ${response.message()}"
                    )
                    if (response.isSuccessful) {
                        Log.i(TAG, "onResponse Body => ${response.body()}")
                        response.body()?.apply {
                            Log.d(TAG, "진도탐색 단원 타이틀 ")
                                this.data?.let {
                                    mAdapter.addItems(it)
                                    setCurrentPosition()
                                }
                        }
                    }
                }
            })
    }

    // 선택 단원 Position (무한 스크롤을 제외하고 다시 적용?)
    private fun setCurrentPosition() {
        Log.d(TAG, "setCurrentPosition")
        if (jindoTitle.isNullOrEmpty()) {
            Log.e(TAG, "jindoTilt is Null")
        } else {
            binding.rvUnit.apply {
                val position = mAdapter.getPosition(jindoTitle)
                Log.e(TAG,"jindoTitle Position => $position")
                (layoutManager as LinearLayoutManager).scrollToPositionWithOffset(position, top)
                mAdapter.setCurrent(position)
                Log.d(TAG, "Unit mAdapter Position => $position")
            }

        }
    }
}