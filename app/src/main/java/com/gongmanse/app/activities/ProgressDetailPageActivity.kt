package com.gongmanse.app.activities

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.progress.ProgressDetailRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityProgressDetailPageBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.ProgressData
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.GBLog
import com.gongmanse.app.utils.Preferences
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class ProgressDetailPageActivity : AppCompatActivity(), SwipeRefreshLayout.OnRefreshListener,
    View.OnClickListener {

    companion object {
        private val TAG = ProgressDetailPageActivity::class.java.simpleName
    }

    private val videoIds: MutableList<String> = mutableListOf()
    private lateinit var binding: ActivityProgressDetailPageBinding
    private lateinit var query: HashMap<String, String>
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mAdapter: ProgressDetailRVAdapter
    private val linearLayoutManager = LinearLayoutManager(this)
    private var jindoId: String = ""
    private var mOffset = 0


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_progress_detail_page)
        initView()

    }

    override fun onPause() {
        GBLog.i("TAG","onPause")
        binding.rvVideo.pausePlayer()

        super.onPause()
    }

    override fun onDestroy() {
        GBLog.i("TAG","onDestroy")
        binding.rvVideo.releasePlayer()
        super.onDestroy()
    }

    override fun onRefresh() {
        Log.d(TAG, "onRefresh()")
        binding.refreshLayout.isRefreshing = false
        mAdapter.clear()
        videoIds.clear()
        binding.rvVideo.pausePlayer()
        prepareData()
    }

    private fun initView() {
        Log.d(TAG, "initView()")
        binding.refreshLayout.setOnRefreshListener(this)
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_progress)
        binding.layoutTitleUnit.title = Constants.ACTIONBAR_TITLE_JINDO
        if (intent.hasExtra(Constants.EXTRA_KEY_PROGRESS)) {
            intent.getSerializableExtra(Constants.EXTRA_KEY_PROGRESS).let {
                val progressData = it as ProgressData
                Log.i(TAG, "ProgressData => $progressData")
                jindoId = progressData.id.toString()
                binding.layoutDetailHeader.data = progressData
            }
        }
        binding.layoutVideoCount.swAutoPlay.setOnCheckedChangeListener { _, isChecked ->
            mAdapter.autoPlay(
                isChecked
            )
        }
        initRVLayout()
        prepareData()
        binding.layoutVideoCount.swAutoPlay.isChecked = true
    }

    private fun initRVLayout() {
        Log.d(TAG, "initRVLayout")
        val items = ObservableArrayList<VideoData>()
        mAdapter = ProgressDetailRVAdapter(this).apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.rvVideo.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.btn_close -> {
                onBackPressed()
            }
            R.id.layout_title_unit -> {
                scrollToTop()
            }
        }
    }

    fun scrollToTop() {
        binding.rvVideo.smoothScrollToPosition(0)
    }

    private fun listener(query: HashMap<String, String>) {
        Log.d(TAG, "loadDetailPage :: jindo_id => $jindoId")

        RetrofitClient.getService()
            .getJindoDetail(jindoId.toInt(), query[Constants.REQUEST_KEY_OFFSET]!!)
            .enqueue(object : Callback<VideoList> {
                override fun onFailure(call: Call<VideoList>, t: Throwable) {
                    Log.e(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(
                    call: Call<VideoList>,
                    response: Response<VideoList>
                ) {
                    if (!response.isSuccessful) Log.d(
                        TAG,
                        "Failed API code : ${response.code()}\n message : ${response.message()}"
                    )
                    if (response.isSuccessful) {
                        response.body()?.apply {
                            Log.d(TAG, "진도 탐색 세부 화면 on Response Body => ${response.body()}")
                            if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                                binding.setVariable(BR.item, this)

                                val temp: String = this.totalNum.toString()
                                temp.let {
                                    val totalNum = temp.toInt()
                                    binding.layoutVideoCount.totalNum = totalNum
                                }

                                // set recyclerView's videoIds
                                this.data?.let {
                                    it.map { data ->
                                        videoIds.add(data.id!!)
                                    }
                                    binding.rvVideo.videoIds = videoIds
                                    binding.rvVideo.checkSmallItemList()
                                }
                            } else {
                                this.data?.let {
                                    mAdapter.addItems(it)

                                    // add recyclerView's videoIds
                                    it.map { data ->
                                        videoIds.add(data.id!!)
                                    }
                                    binding.rvVideo.videoIds = videoIds
                                    binding.rvVideo.checkSmallItemList()
                                }
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
                if (mOffset != totalItemsCount) loadMoreData(totalItemsCount)
            }
        }

        // 스크롤 이벤트 초기화
        binding.rvVideo.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        // 추가 호출
        Log.d(TAG, "loadMoreData => $offset")
        mOffset = offset
        query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
        listener(query)
    }

    fun moveLoginActivity(intent: Intent) {
        requestLoginActivity.launch(intent)
    }

    private val requestLoginActivity: ActivityResultLauncher<Intent> =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { activityResult ->
            if (activityResult.resultCode == Activity.RESULT_OK) {
                if (Preferences.token.isNotEmpty()) {
                    Constants.getProfile()
                } else {
                    Log.v(TAG,"Preferences.token is null")
                }
            } else {
                Log.v(TAG,"activity resultCode is null")
            }
        }
}