package com.gongmanse.app.fragments.active

import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.facebook.common.Common
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.active.QuestionRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentActiveQuestionBinding
import com.gongmanse.app.fragments.sheet.SelectionSheetSpinner
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetSpinnerListener
import com.gongmanse.app.listeners.OnHeaderListener
import com.gongmanse.app.model.Counsel
import com.gongmanse.app.model.CounselData
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

@Suppress("DEPRECATION")
class ActiveQuestionFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener, OnBottomSheetSpinnerListener, OnHeaderListener {

    companion object {
        private val TAG = ActiveQuestionFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentActiveQuestionBinding
    private lateinit var query: HashMap<String, String>
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var bottomSheetSpinner: SelectionSheetSpinner
    private val linearLayoutManager = LinearLayoutManager(this.context)
    private var selectOrder: String = Constants.CONTENT_VALUE_LATEST
    private var mOffset = 0
    private var isLoading = false
    private val type = 6
    var mAdapter: QuestionRVAdapter? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_active_question, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onRefresh() {
        binding.layoutRefresh.isRefreshing = false
        mOffset = 0
        mAdapter?.clear()
        prepareData()
    }

    override fun selectionSpinner(value: String) {
        binding.layoutHeader.tvSpinner.text = value
        selectOrder = value
        mAdapter?.apply {
            clear()
            addSortId(Commons.getSortToId(value))
        }
        onRefresh()
    }

    override fun updateTotalNum(isRemoved: Boolean) {
        val total = binding.layoutHeader.totalNum
        total?.let {
            if (it > 0) binding.layoutHeader.totalNum = it.minus(1)
            if (it > 20) loadOneData()
        }
    }

    private fun initView() {
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_question)
        binding.layoutHeader.tvSpinner.text = selectOrder
        binding.layoutRefresh.setOnRefreshListener(this)
        binding.layoutHeader.tvSpinner.setOnClickListener {
            bottomSheetSpinner = SelectionSheetSpinner(this, selectOrder, type)
            selectSpinner()
        }
        initRVLayout()
        prepareData()
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<CounselData>()
        mAdapter = QuestionRVAdapter(this).apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.recyclerView.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun selectSpinner() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetSpinner.show(supportManager, bottomSheetSpinner.tag)
    }

    private fun listener(query: HashMap<String, String>) {
        val sortId: Int = when (selectOrder) {
            Constants.CONTENT_VALUE_LATEST -> Constants.CONTENT_RESPONSE_VALUE_LATEST
            Constants.CONTENT_VALUE_VIEWS  -> Constants.CONTENT_RESPONSE_VALUE_VIEWS
            Constants.CONTENT_VALUE_ANSWER -> Constants.CONTENT_RESPONSE_VALUE_ANSWER
            else                           -> Constants.CONTENT_RESPONSE_VALUE_LATEST
        }
        RetrofitClient.getService().getQuestionList(Preferences.token, sortId, query[Constants.REQUEST_KEY_OFFSET]!!, query[Constants.REQUEST_KEY_LIMIT]!!).enqueue(object: Callback<Counsel> {
            override fun onFailure(call: Call<Counsel>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                binding.layoutHeader.totalNum = 0
            }

            override fun onResponse(call: Call<Counsel>, response: Response<Counsel>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {

                        if (isLoading) {
                            mAdapter?.removeLoading()
                        }

                        setTotalNum(this.totalNum.toString())

                        if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                            binding.setVariable(BR.item, this)
                        } else {
                            this.data?.let {
                                mAdapter?.addItems(it)
                            }
                        }
                        isLoading = false
                    }
                }
            }
        })
    }

    private fun prepareData() {
        // 최초 호출
        Log.d(TAG, "prepareData...")
        query = hashMapOf(Constants.REQUEST_KEY_OFFSET to Constants.OFFSET_DEFAULT, Constants.REQUEST_KEY_LIMIT to Constants.LIMIT_DEFAULT)
        listener(query)

        // 스크롤 이벤트
        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
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
        // 추가 호출
        if (isLoading) {
            mAdapter?.addLoading()
        }
        Handler().postDelayed({
            mOffset = offset
            query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
            listener(query)
        }, Constants.ENDLESS_DELAY_VALUE)
    }

    private fun loadOneData() {
        val sortId: Int = when (selectOrder) {
            Constants.CONTENT_VALUE_AVG     -> Constants.CONTENT_RESPONSE_VALUE_AVG
            Constants.CONTENT_VALUE_LATEST  -> Constants.CONTENT_RESPONSE_VALUE_LATEST
            Constants.CONTENT_VALUE_NAME    -> Constants.CONTENT_RESPONSE_VALUE_NAME
            Constants.CONTENT_VALUE_SUBJECT -> Constants.CONTENT_RESPONSE_VALUE_SUBJECT
            else                            -> Constants.CONTENT_RESPONSE_VALUE_LATEST
        }
        RetrofitClient.getService().getQuestionList(Preferences.token, sortId, "19", "1").enqueue(object: Callback<Counsel> {
            override fun onFailure(call: Call<Counsel>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                binding.layoutHeader.totalNum = 0
            }

            override fun onResponse(call: Call<Counsel>, response: Response<Counsel>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.v(TAG, "onResponse => $this")
                        this.data?.let { if (it.size > 0) mAdapter?.addItems(it) }
                    }
                }
            }
        })
    }

    private fun setTotalNum(num: String?) {
        if (num != null ) binding.layoutHeader.totalNum = num.toInt()
        else binding.layoutHeader.totalNum = 0
    }

    fun setRemoveMode() {
        Log.d(TAG, "setRemoveMode()")
        mAdapter?.setRemoveMode()
    }

    fun setNormalMode() {
        Log.d(TAG, "setNormalMode()")
        mAdapter?.setNormalMode()
    }

    fun moveTopPosition() {
        binding.recyclerView.smoothScrollToPosition(0)
    }

}