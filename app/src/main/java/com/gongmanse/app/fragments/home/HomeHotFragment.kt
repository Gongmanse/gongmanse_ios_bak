package com.gongmanse.app.fragments.home

import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.R
import com.gongmanse.app.adapter.home.HomeHotRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentHotBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

@Suppress("DEPRECATION")
class HomeHotFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = HomeHotFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentHotBinding
    private lateinit var mRecyclerAdapter :HomeHotRVAdapter
    private lateinit var scrollListener: EndlessRVScrollListener
    private val linearLayoutManager = LinearLayoutManager(context)
    private var mOffset: Int = 0
    private var isLoading = false

    override fun onRefresh() {
        Log.d(TAG, "HotFragment:: onRefresh()")
        mRecyclerAdapter.clear()
        prepareData()
        binding.refreshLayout.isRefreshing = false
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater,R.layout.fragment_hot, container, false)
        initView()
        loadData()
        return binding.root
    }

    private fun initView() {
        Log.d(TAG, "HotFragment:: initView()")
        binding.refreshLayout.setOnRefreshListener(this)
        binding.refreshLayout.isRefreshing = false
        setRVLayout()
    }
    private fun loadData() {
        prepareData()
    }
    fun scrollToTop(){
        binding.rvVideo.smoothScrollToPosition(0)
    }
    private fun setRVLayout() {
        binding.rvVideo.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            layoutManager = linearLayoutManager
        }
        if (binding.rvVideo.adapter == null) {
            mRecyclerAdapter =HomeHotRVAdapter()
            binding.rvVideo.adapter = mRecyclerAdapter
        }
    }

    private fun loadVideo(offset:Int) {
        var sGrade : String? = null
        if(Preferences.grade.isEmpty()){
            Log.d(TAG, "Preferences.grade => ${Preferences.grade}")
        }else {
            sGrade = when (Preferences.grade[0]) {
                '초' -> Constants.CONTENT_VALUE_ELEMENTARY
                '중' -> Constants.CONTENT_VALUE_MIDDLE
                '고' -> Constants.CONTENT_VALUE_HIGH
                else -> null
            }
        }

        Log.d(TAG, "sGrade.grade => $sGrade")
        RetrofitClient.getService().getHotList(offset,sGrade).enqueue( object :Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                Log.e("Retrofit : onFailure ", "Failed API call with call : $call\nexception : $t")
            }
            override fun onResponse(
                call: Call<VideoList>,
                response: Response<VideoList>
            ) {
                if (!response.isSuccessful) Log.d("Retrofit :responseFail", "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    Log.d("Retrofit : isSuccessful", "onResponse => $this")
                    Log.i("Retrofit : isSuccessful", "onResponse Body => ${response.body()}")
                    response.body()?.apply {
                        if (isLoading) {
                            mRecyclerAdapter.removeLoading()
                        }
                        mRecyclerAdapter.addItems(this.data as List<VideoData>)
                        isLoading = false
                    }
                }
            }
        })
    }
    private fun prepareData() {
        // 최초 호출
        Log.d(TAG, "prepareData...")
        loadVideo(mOffset)

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
        binding.rvVideo.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        Log.d(TAG, "loadMoreData : isLoading => $isLoading")
        if (isLoading) {
            mRecyclerAdapter.addLoading()
        }
        Handler().postDelayed({
            mOffset = offset
            loadVideo(mOffset)
        }, Constants.ENDLESS_DELAY_VALUE)
    }

}