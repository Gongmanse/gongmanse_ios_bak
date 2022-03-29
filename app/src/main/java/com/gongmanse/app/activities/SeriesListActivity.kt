package com.gongmanse.app.activities

import android.annotation.SuppressLint
import android.graphics.Color
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.R
import com.gongmanse.app.adapter.home.HomeSeriesRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivitySeriesListBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.GBLog
import kotlinx.android.synthetic.main.activity_teacher_detail.*
import kotlinx.android.synthetic.main.layout_video_header.view.*
import org.jetbrains.anko.textColor
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import kotlin.properties.Delegates

class SeriesListActivity : AppCompatActivity(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = SeriesListActivity::class.java.simpleName
    }

    private val mRecyclerAdapter by lazy { HomeSeriesRVAdapter() }
    private lateinit var binding: ActivitySeriesListBinding
    private val linearLayoutManager = LinearLayoutManager(this)
    private lateinit var scrollListener: EndlessRVScrollListener
    private var page = 0
    private var seriesId by Delegates.notNull<Int>()
    private val isChecked = false
    private val videoIds: MutableList<String> = mutableListOf()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_series_list)

        initData()
        initView()
    }

    override fun onRefresh() {
        binding.refreshLayout.isRefreshing = false
        page = 0
        binding.rvVideo.removeAllViewsInLayout()
        mRecyclerAdapter.clear()
        videoIds.clear()
        binding.rvVideo.pausePlayer()
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

    private fun initView() {
        headerBinding()
        setRVLayout()
        prepareData()
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_SERIES
        binding.refreshLayout.setOnRefreshListener(this)


        // 자동재생 버튼 삭제 요청으로 인한 주석처리 및 코드 추가
        tv_video_count.sw_auto_play.visibility = View.GONE
        mRecyclerAdapter.autoPlay(isChecked)
//        binding.tvVideoCount.swAutoPlay.setOnCheckedChangeListener { buttonView, isChecked ->
//            mRecyclerAdapter.autoPlay(isChecked)
//        }



        binding.layoutToolbar.btnClose.setOnClickListener {
            onBackPressed()
        }
        binding.tvVideoCount.swAutoPlay.isChecked = false
    }

    private fun initData(){
        if (intent.hasExtra(Constants.REQUEST_KEY_SERIES_ID)){
            val sSeriesId = intent.getStringExtra(Constants.REQUEST_KEY_SERIES_ID).toString()
            seriesId = sSeriesId.toInt()
            Log.d("series_id", "${seriesId}")
        }else{
            toast("잘못된 동영상 입니다.")
            finish()
        }
    }



    private fun setRVLayout() {
        binding.rvVideo.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            layoutManager = linearLayoutManager
        }
        if (binding.rvVideo.adapter == null) {
            binding.rvVideo.adapter = mRecyclerAdapter
        }
    }
//
//    private fun prepareData() {
//        loadVideo(page)
//
//
//        // 스크롤 이벤트
//        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
//            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
//                if(page != totalItemsCount) loadMoreData(totalItemsCount,loadVideo(totalItemsCount))
//                Log.d("total" , "$totalItemsCount")
//            }
//        }
//        // 스크롤 이벤트 초기화
//        binding.rvVideo.addOnScrollListener(scrollListener)
//        scrollListener.resetState()
//    }
//
//    private fun loadMoreData(offset: Int ,function :Unit) {
//        page = offset
//    }

    private fun prepareData() {
        // 최초 호출
        loadVideo(this.seriesId, page)

        // 스크롤 이벤트

        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if(page != totalItemsCount)  loadMoreData(totalItemsCount)
            }
        }
        binding.rvVideo.addOnScrollListener(scrollListener)
        scrollListener.resetState()

    }

    private fun loadMoreData(offset: Int) {
        page = offset
        loadVideo(this.seriesId,page)
    }

    private fun loadVideo(id : Int,offset: Int) {
        RetrofitClient.getService().getSeriesList(id, offset,Constants.LIMIT_DEFAULT).enqueue( object :
            Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }
            override fun onResponse(
                call: Call<VideoList>,
                response: Response<VideoList>
            ) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    Log.d(TAG, "onResponse => $this")
                    Log.i(TAG, "onResponse Body => ${response.body()}")
                    response.body()?.apply {
                        this.data.let{
                            mRecyclerAdapter.addItems(it as List<VideoData>,id)
                            // set recyclerView's videoIds
                            it.map { data ->
                                videoIds.add(data.id!!)
                            }
                            binding.rvVideo.videoIds = videoIds
                            binding.rvVideo.checkSmallItemList()
                        }
                        this.totalNum?.let{
                            val temp = this.totalNum.toInt()
                            binding.tvVideoCount.totalNum = temp
                        }
                    }
                }
            }
        })
    }

    @SuppressLint("SetTextI18n")
    private fun headerBinding(){
        if (intent.hasExtra(Constants.EXTRA_KEY_ITEM)){
            val item = intent.getSerializableExtra(Constants.EXTRA_KEY_ITEM) as VideoData
            val grade = intent.getStringExtra(Constants.EXTRA_KEY_GRADE)
            binding.layoutDetailHeader.apply {
                tvTitle.text = item.title
                tvClass.text = grade
                tvClass.textColor =  Color.parseColor("#"+item.subjectColor)
                tvTeacherName.text = "${item.teacherName} ${Constants.CONTENT_VALUE_TEACHER}"
                tvSubject.text = item.subject
                layoutCv.setCardBackgroundColor(Color.parseColor(Constants.CONTENT_VALUE_COLOR+item.subjectColor))
            }
        }

    }
}