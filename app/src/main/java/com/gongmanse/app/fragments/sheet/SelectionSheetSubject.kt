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
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.bindViewSearchSubjectListData
import com.gongmanse.app.adapter.search.SearchSubjectRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.DialogSheetSelectionOfSubjectBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetSubjectListener
import com.gongmanse.app.model.ProgressData
import com.gongmanse.app.model.SearchSubjectList
import com.gongmanse.app.model.SearchSubjectListData
import com.gongmanse.app.utils.Constants
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class SelectionSheetSubject(private val listener: OnBottomSheetSubjectListener, var subject: String? = null) : BottomSheetDialogFragment() {

    companion object {
        private val TAG = SelectionSheetSubject::class.java.simpleName
    }

    private lateinit var binding: DialogSheetSelectionOfSubjectBinding
    private lateinit var mAdapter: SearchSubjectRVAdapter
    private val linearLayoutManager = LinearLayoutManager(context)
    private val limit: Int = 50


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = DataBindingUtil.inflate(inflater, R.layout.dialog_sheet_selection_of_subject, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        binding.btnClose.setOnClickListener { dismiss() }
        initRVLayout()
        loadSubjectList()
    }

    private fun initRVLayout() {
        Log.d(TAG, "initRVLayout()")
        val items = ObservableArrayList<SearchSubjectListData>()
        items.add(0, SearchSubjectListData(null, Constants.CONTENT_VALUE_ALL_SUBJECT))
        Log.d(TAG, "items => $items")
        mAdapter = SearchSubjectRVAdapter(listener).apply {
            addItems(items)
        }
        binding.rvSubject.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
            addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL))
        }

    }

    private fun loadSubjectList() {
        RetrofitClient.getService().getSubjectNum(Constants.OFFSET_DEFAULT, limit).enqueue( object : Callback<SearchSubjectList> {
            override fun onFailure(call: Call<SearchSubjectList>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(
                call: Call<SearchSubjectList>,
                response: Response<SearchSubjectList>
            ) {
                if (response.isSuccessful) {
                    response.body()?.apply {
                        this.data.let {
                            if (it != null) {
                                mAdapter.addItems(it)
                                setCurrentPosition()
                            }
                        }
                    }
                } else Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
            }
        })
    }

    private fun setCurrentPosition() {
        Log.d(TAG, "setCurrentPosition")
        if (subject.isNullOrEmpty()){
            Log.e(TAG, "subject is null")
        } else {
            binding.rvSubject.apply {
                val position = mAdapter.getPosition(subject)
                (layoutManager as LinearLayoutManager).scrollToPositionWithOffset(position, top)
                mAdapter.setCurrent(position)
            }
        }
    }
}

