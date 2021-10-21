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
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.search.SearchHotRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentSearchHotBinding
import com.gongmanse.app.fragments.sheet.SelectionSheetGrade
import com.gongmanse.app.fragments.video.VideoQNASFragment
import com.gongmanse.app.listeners.OnSearchKeywordListener
import com.gongmanse.app.model.SearchHotList
import com.gongmanse.app.model.SearchHotListData
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response



class SearchHotFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = SearchHotFragment::class.java.simpleName
        private lateinit var listener: OnSearchKeywordListener
        fun newInstance(ls: OnSearchKeywordListener) = SearchHotFragment().apply {
            arguments = bundleOf()
            listener = ls
        }
    }

    private lateinit var binding: FragmentSearchHotBinding
    private lateinit var mAdapter: SearchHotRVAdapter
    private val linearLayoutManager = LinearLayoutManager(context)

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_search_hot, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onRefresh() {
        Log.d(TAG, "onRefresh()")
        binding.layoutRefresh.isRefreshing = false
        mAdapter.clear()
        loadHotSearchList()
    }

    fun scrollToTop() = binding.rvHotList.smoothScrollToPosition(0)

        private fun initView() {
            Log.d(TAG, "initView()")
            binding.layoutEmpty.title = resources.getString(R.string.content_empty_search_hot)
            binding.layoutRefresh.setOnRefreshListener(this)
            initRVLayout()
            loadHotSearchList()
        }

        private fun initRVLayout() {
            Log.d(TAG, "initRVLayout")
            val items = ObservableArrayList<SearchHotListData>()
            mAdapter = SearchHotRVAdapter(listener).apply {
                setHasStableIds(true)
                addItems(items)
            }
            binding.rvHotList.apply {
                adapter = mAdapter
                layoutManager = linearLayoutManager
            }
        }

        private fun loadHotSearchList() {
            Log.d(TAG, "loadHotSearchList()")
            RetrofitClient.getService().getHotSearchList().enqueue(object : Callback<SearchHotList> {
                override fun onFailure(call: Call<SearchHotList>, t: Throwable) {
                    Log.e(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(
                    call: Call<SearchHotList>,
                    response: Response<SearchHotList>
                ) {
                    if (response.isSuccessful) {
                        response.body()?.apply {
                            Log.d(TAG, "인기 검색어")
                            Log.i(TAG, "onResponseBody => ${response.body()}")
                            binding.setVariable(BR.item, this)
                        }

                    }
                }
            })

        }
    }
