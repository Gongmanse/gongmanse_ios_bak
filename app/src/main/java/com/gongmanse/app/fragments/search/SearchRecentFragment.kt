package com.gongmanse.app.fragments.search

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.search.SearchRecentRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentSearchRecentBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnSearchKeywordListener
import com.gongmanse.app.model.SearchRecentList
import com.gongmanse.app.model.SearchRecentListData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class SearchRecentFragment : Fragment() {

    companion object {
        private val TAG = SearchRecentFragment::class.java.simpleName
        private lateinit var listener: OnSearchKeywordListener
        fun newInstance(ls: OnSearchKeywordListener) = SearchRecentFragment().apply {
            arguments = bundleOf()
            listener = ls
        }
    }

    private lateinit var binding: FragmentSearchRecentBinding
    private lateinit var mAdapter: SearchRecentRVAdapter
    private lateinit var query: HashMap<String, String>
    private lateinit var scrollListener: EndlessRVScrollListener
    private var mOffset = 0
    private val linearLayoutManager = LinearLayoutManager(context)


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_search_recent, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onResume() {
        super.onResume()
        Log.e(TAG, "onResume!!!")
        initView()
    }

    fun scrollToTop() = binding.rvRecentList.smoothScrollToPosition(0)

    private fun initView() {
        Log.d(TAG, "initView()")
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_search_recent)
        initRVLayout()

        if (Preferences.token.isNotEmpty()) prepareData()
    }

    private fun initRVLayout() {
        Log.d(TAG, "initRVLayout()")
        val items = ObservableArrayList<SearchRecentListData>()
        mAdapter = SearchRecentRVAdapter(listener).apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.rvRecentList.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun listener(query: HashMap<String, String>) {
        Log.d(TAG, "loadRecentSearchList()")
        Log.e(TAG, "Token => ${Preferences.token}")
        RetrofitClient.getService().getRecentSearchList(
            Preferences.token,
            query[Constants.REQUEST_KEY_OFFSET]!!,
            Constants.LIMIT_DEFAULT
        ).enqueue(object : Callback<SearchRecentList> {
            override fun onFailure(call: Call<SearchRecentList>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(
                call: Call<SearchRecentList>,
                response: Response<SearchRecentList>
            ) {
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.i(TAG, "onResponse Body => ${response.body()}")
                        if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                            binding.setVariable(BR.item, this)
                        } else {
                            this.data?.let { mAdapter.addItems(it) }
                        }

                    }
                }
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
                if (mOffset != totalItemsCount && totalItemsCount >= 20) loadMoreData(
                    totalItemsCount
                )
            }
        }

        // 스크롤 이벤트 초기화
        binding.rvRecentList.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        // 추가 호출
        Log.d(TAG, "loadMoreData => $offset")
        mOffset = offset
        query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
        listener(query)
    }

}