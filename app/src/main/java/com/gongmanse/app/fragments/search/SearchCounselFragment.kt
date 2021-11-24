package com.gongmanse.app.fragments.search

import android.os.Bundle
import android.os.Handler
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.counsel.CounselListAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentSearchCounselBinding
import com.gongmanse.app.fragments.sheet.SelectionSheetSpinner
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetSpinnerListener
import com.gongmanse.app.model.Counsel
import com.gongmanse.app.model.CounselData
import com.gongmanse.app.utils.Constants
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

@Suppress("DEPRECATION")
class SearchCounselFragment(private val keyword:String?,  private var from: Boolean) : Fragment(), OnBottomSheetSpinnerListener {

    companion object {
        private val TAG = SearchCounselFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentSearchCounselBinding
    private lateinit var query: HashMap<String, String>
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mAdapter: CounselListAdapter
    private lateinit var bottomSheetSpinner: SelectionSheetSpinner
    private val type = 6
    private var mOffset = 0
    private var isLoading = false
    private var selectOrder: String = Constants.CONTENT_VALUE_LATEST
    private val linearLayoutManager = LinearLayoutManager(this.context)


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_search_counsel, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    fun scrollToTop() {
        binding.rvCounselList.smoothScrollToPosition(0)
    }

    private fun initView() {
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_counsel)
        initRVLayout()
        prepareData()
        binding.layoutHeader.tvSpinner.setOnClickListener {
            bottomSheetSpinner = SelectionSheetSpinner(this, binding.layoutHeader.tvSpinner.text.toString(), type )
            selectSpinner()
        }
    }

    private fun selectSpinner() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetSpinner.show(supportManager, bottomSheetSpinner.tag)    }

    override fun selectionSpinner(value: String) {
        binding.layoutHeader.tvSpinner.text = value
        selectOrder = value
        mOffset = 0
        mAdapter.clear()
        initView()
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<CounselData>()
        mAdapter = CounselListAdapter().apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.rvCounselList.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun listener(query: HashMap<String, String>) {
        var sortId: Int? = null

        when (selectOrder) {
            Constants.CONTENT_VALUE_LATEST -> sortId = Constants.CONTENT_RESPONSE_VALUE_LATEST
            Constants.CONTENT_VALUE_VIEWS  -> sortId = Constants.CONTENT_RESPONSE_VALUE_VIEWS
            Constants.CONTENT_VALUE_ANSWER -> sortId = Constants.CONTENT_RESPONSE_VALUE_ANSWER
        }

        RetrofitClient.getService().getSearchCounselList(keyword, sortId, query[Constants.REQUEST_KEY_OFFSET]!!,Constants.LIMIT_DEFAULT).enqueue(object : Callback<Counsel> {
            override fun onFailure(call: Call<Counsel>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
                binding.layoutHeader.totalNum = 0
            }

            override fun onResponse(call: Call<Counsel>, response: Response<Counsel>) {
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.i(TAG, "onResponse Body => ${response.body()}")
                        if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                            setTotalNum(this.totalNum?.toInt())
                            isLoadingCheck(isLoading)
                            binding.setVariable(BR.item, this)
                        } else {
                            this.data?.let {
                                setTotalNum(this.totalNum?.toInt())
                                isLoadingCheck(isLoading)
                                mAdapter.addItems(it)
                            }
                        }
                        isLoading = false
                    }
                }
                else Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
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
        binding.rvCounselList.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        Log.d(TAG, "loadMoreData => $offset")
        if (isLoading) {
            binding.rvCounselList.post {
                mAdapter.addLoading()
            }
        }
        val handler = Handler()
        handler.postDelayed({
            mOffset = offset
            query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
            listener(query)
        }, Constants.ENDLESS_DELAY_VALUE)
    }

    private fun isLoadingCheck(loading: Boolean) {
        Log.d(TAG,"loading : $loading")
        if (isLoading) mAdapter.removeLoading()
    }

    private fun setTotalNum(totalNum: Int?) {
        Log.e(TAG,"setTotalNum => $totalNum")
        if (totalNum != null ) binding.layoutHeader.totalNum = totalNum
        else binding.layoutHeader.totalNum = 0
    }

}