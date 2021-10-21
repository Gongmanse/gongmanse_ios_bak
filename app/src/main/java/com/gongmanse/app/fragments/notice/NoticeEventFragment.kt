package com.gongmanse.app.fragments.notice

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.notice.EventRVAdapter
import com.gongmanse.app.adapter.notice.NoticeRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentNoticeEventBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.Event
import com.gongmanse.app.model.EventData
import com.gongmanse.app.model.Notice
import com.gongmanse.app.model.NoticeData
import com.gongmanse.app.utils.Constants
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class NoticeEventFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = NoticeEventFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentNoticeEventBinding
    private lateinit var mAdapter: EventRVAdapter
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var query: HashMap<String, String>
    private val linearLayoutManager = LinearLayoutManager(context)
    private var mOffset = 0


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_notice_event, container, false)
        return  binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onRefresh() {
        binding.layoutRefresh.isRefreshing = false
        mAdapter.clear()
        prepareData()
    }

    fun scrollToTop() = binding.rvEvent.smoothScrollToPosition(0)

    private fun initView() {
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_notice_event)
        binding.layoutRefresh.setOnRefreshListener(this)
        initRVLayout()
        prepareData()
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<EventData>()
        mAdapter = EventRVAdapter().apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.rvEvent.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun listener(query: HashMap<String, String>) {
        Log.d(TAG, "loadEventList()")
        RetrofitClient.getService().getNoticeEventList(query[Constants.REQUEST_KEY_OFFSET]!!,  Constants.LIMIT_DEFAULT).enqueue( object : Callback<Event> {
            override fun onFailure(call: Call<Event>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Event>, response: Response<Event>) {
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.d(TAG, "이벤트 목록")
                        Log.i(TAG, "onResponseBody => ${response.body()}")
                        if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                            binding.setVariable(BR.event, this)
                        } else {
                            this.data?.let { mAdapter.addItems(it) }
                        }
                    }
                } else Log.e(TAG,"Failed ResponseCode => ${response.code()}")
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
                if (mOffset != totalItemsCount && totalItemsCount >= 20) loadMoreData(totalItemsCount)
            }
        }

        // 스크롤 이벤트 초기화
        binding.rvEvent.addOnScrollListener(scrollListener)
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