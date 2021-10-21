package com.gongmanse.app.fragments.sheet

import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.active.QNADetailRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.DialogSheetSelectionOfQnaBinding
import com.gongmanse.app.fragments.progress.ProgressKEMFragment
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetRemoveQNAListener
import com.gongmanse.app.model.QNADetail
import com.gongmanse.app.model.QNADetailData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class SelectionSheetQNA(
    private val videoId: String,
    private val title: String,
    private val listener: OnBottomSheetRemoveQNAListener
) : BottomSheetDialogFragment() {

    companion object {
        private val TAG = SelectionSheetQNA::class.java.simpleName
    }

    private lateinit var binding: DialogSheetSelectionOfQnaBinding
    private lateinit var mAdapter: QNADetailRVAdapter
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var query: HashMap<String, String>
    private var mOffset: Int = 0
    private var isLoading = false
    private val linearLayoutManager = LinearLayoutManager(context)

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.dialog_sheet_selection_of_qna, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        binding.btnClose.setOnClickListener { dismiss() }
        binding.btnSelectAll.setOnClickListener { mAdapter.setAllChecked() }
        binding.btnSelectRemove.setOnClickListener {
            listener.removeItems(mAdapter.removeItems(), mAdapter.removeItemsSize())
        }
        initView()
    }

    private fun initView() {
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_qna)
        binding.setVariable(BR.title, title)
        initRVLayout()
        prepareData()
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<QNADetailData>()
        mAdapter = QNADetailRVAdapter().apply {
            setHasStableIds(true)
            addItems(items)
        }
        val dividerItemDecoration = DividerItemDecoration(context, linearLayoutManager.orientation)
        context?.let { c ->
            ContextCompat.getDrawable(c, R.drawable.divider)?.let { icon ->
                dividerItemDecoration.setDrawable(icon)
            }
        }
        binding.recyclerView.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
            addItemDecoration(dividerItemDecoration)
        }
    }

    private fun listener(query: HashMap<String, String>) {
        RetrofitClient.getService().getQNADetailContents(
            Preferences.token,
            videoId,
            query[Constants.REQUEST_KEY_OFFSET]!!,
            Constants.LIMIT_DEFAULT
        ).enqueue(object : Callback<QNADetail> {
            override fun onFailure(call: Call<QNADetail>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<QNADetail>, response: Response<QNADetail>) {
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.d(TAG, "onResponse => $this")
//                        binding.setVariable(BR.item, this)
                        if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                            isLoadingCheck(isLoading)
                            binding.setVariable(BR.item, this)
                        } else {
                            this.data?.let {
                                isLoadingCheck(isLoading)
                                mAdapter.addItems(it)
                            }
                        }
                        isLoading = false
                    }
                } else Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
            }
        })
    }

    private fun prepareData() {
        // 최초 호출
        Log.d(TAG, "prepareData...")
        query = hashMapOf(Constants.REQUEST_KEY_OFFSET to Constants.OFFSET_DEFAULT)
        listener(query)

        // 스크롤 이벤트
        scrollListener = object : EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if (!isLoading && mOffset != totalItemsCount && totalItemsCount >= 20) {
                    isLoading = true
                    loadMoreData(totalItemsCount)
                }
            }
        }

        // 스크롤 이벤트 초기화
        binding.recyclerView.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        if (isLoading) mAdapter.addLoading()
        val handler = Handler()
        handler.postDelayed({
            mOffset = offset
            query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
            listener(query)
        }, Constants.ENDLESS_DELAY_VALUE)
    }

    private fun isLoadingCheck(loading: Boolean) {
        Log.d(TAG, "loading : $loading")
        if (isLoading) mAdapter.removeLoading()
    }
}