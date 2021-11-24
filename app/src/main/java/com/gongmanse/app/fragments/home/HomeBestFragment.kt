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
import com.gongmanse.app.adapter.home.HomeBestAdapter1
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentBestBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import kotlin.text.isNullOrEmpty as isNullOrEmpty

@Suppress("DEPRECATION")
class HomeBestFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = HomeBestFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentBestBinding
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var query: HashMap<String, String>
    private lateinit var mViewpagerAdapter: HomeBestAdapter1
    private val linearLayoutManager = LinearLayoutManager(context)
    private var mOffset: Int = 0
    private var isLoading = false

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_best, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onRefresh() {
        binding.refreshLayout.isRefreshing = false
        mViewpagerAdapter.clear()
        prepareData()
    }

    private fun initView() {
        Log.d(TAG, "BestFragment:: initView()")
        binding.refreshLayout.setOnRefreshListener(this)
        setRVLayout()
        prepareData()
    }

    fun scrollToTop() {
        binding.rvVideo.smoothScrollToPosition(0)
    }

    private fun setRVLayout() {
        binding.rvVideo.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            layoutManager = linearLayoutManager
        }
        if (binding.rvVideo.adapter == null) {
            mViewpagerAdapter = HomeBestAdapter1()
            binding.rvVideo.adapter = mViewpagerAdapter
        }
    }

    private fun loadVideo(offset: Int) {
        Log.d(TAG, "loadVideo.grade => $offset")
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
        RetrofitClient.getService().getBestList(sGrade, offset).enqueue(object : Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                Log.e("Retrofit : onFailure ", "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<VideoList>, response: Response<VideoList>) {
                if (!response.isSuccessful) {
                    Log.d("Retrofit :responseFail", "Failed API code : ${response.code()}\n message : ${response.message()}")
                }
                if (response.isSuccessful) {
                    Log.d("Retrofit : isSuccessful", "onResponse => $this")
                    Log.i("Retrofit : isSuccessful", "onResponse Body => ${response.body()}")
                    response.body()?.apply {
                        Log.d(TAG, "Retrofit : isLoading => $isLoading")
                        if (isLoading) {
                            mViewpagerAdapter.removeLoading()
                        }
                        mViewpagerAdapter.addItems(this.data as List<VideoData>)
                        isLoading = false
                    }
                }
            }
        })
    }

    private fun prepareData() {
        // 최초 호출
        query = hashMapOf(Constants.REQUEST_KEY_OFFSET to Constants.OFFSET_DEFAULT)
        val bannerData = VideoData().apply { viewType = Constants.BEST_BANNER_TYPE.toString() }
        val titleData = VideoData().apply { viewType = Constants.BEST_TITLE_TYPE.toString() }
        mViewpagerAdapter.addItems(listOf(bannerData, titleData))

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
        Log.e(TAG,"loadMoreData offset => $offset")
        if (isLoading) {
            binding.rvVideo.post {
                mViewpagerAdapter.addLoading()
            }
        }
        Handler().postDelayed({
            mOffset = offset
            query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
            loadVideo(mOffset)
        }, Constants.ENDLESS_DELAY_VALUE)
    }

}
