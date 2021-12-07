package com.gongmanse.app.activities

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.R
import com.gongmanse.app.adapter.teacher.TeacherDetailRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityTeacherDetailBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.Teacher
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.utils.Constants
import kotlinx.android.synthetic.main.activity_teacher_detail.*
import kotlinx.android.synthetic.main.layout_video_header.view.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class TeacherDetailActivity : AppCompatActivity() , SwipeRefreshLayout.OnRefreshListener {

    private lateinit var binding: ActivityTeacherDetailBinding

    companion object {
        private val TAG = TeacherDetailActivity::class.java.simpleName

    }

    private val mRecyclerAdapter by lazy { TeacherDetailRVAdapter() }
    private var id : Int? = null
    private var videoId : Int? = null
    private lateinit var scrollListener: EndlessRVScrollListener
    private val linearLayoutManager = LinearLayoutManager(this)
    private var mOffset : Int = 0
    private val isChecked = false

    override fun onRefresh() {
        refresh_layout.isRefreshing = false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_teacher_detail)
        binding.layoutToolbar.btnClose.setOnClickListener { onBackPressed()  }
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_TEACHER

        loadData()
        initView()
    }

    private fun initView() {

        refresh_layout.setOnRefreshListener(this)
        prepareData()
        setRVLayout()

        // 자동재생 버튼 삭제 요청으로 인한 주석처리 및 코드 추가

        tv_video_count.sw_auto_play.visibility = View.GONE
        mRecyclerAdapter.autoPlay(isChecked)
//        tv_video_count.sw_auto_play.setOnCheckedChangeListener { _, isChecked ->
//            mRecyclerAdapter.autoPlay(isChecked)
//            Log.d("check boll","$isChecked")zzzzz
//        }

    }

    private fun loadData() {
        if (intent.hasExtra(Constants.EXTRA_KEY_TEACHER)) {
            intent.getSerializableExtra(Constants.EXTRA_KEY_TEACHER).let {
                val teacherData = it as Teacher
                Log.i(TAG, "Teacher Data => $teacherData")
                binding.layoutDetailHeader.data = teacherData
            }
            intent.getStringExtra(Constants.REQUEST_KEY_ID).let{
                if (it != null) {
                    id = it.toInt()
                }else{
                    videoId= intent.getStringExtra(Constants.EXTRA_KEY_VIDEO_ID)?.toInt()
                }
            }
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

    private fun loadVideo(id : Int,offset: Int ) {
        Log.i("loadVideo", "Teacher Data => $id")
        mRecyclerAdapter.addId(id)
        RetrofitClient.getService().getSeriesList(id,offset,Constants.LIMIT_DEFAULT).enqueue( object :
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
                    response.body().apply{
                        this?.data.let {
                            mRecyclerAdapter.addItems(it as List<VideoData>)
                        }
                        val temp: String = this!!.totalNum.toString()
                        temp.let{
                            val totalNum = temp.toInt()
                            Log.d("item check" , "${totalNum}")
                            binding.tvVideoCount.totalNum = totalNum
                        }
                    }
                }
            }
        })
    }

    private fun prepareData() {
        // 최초 호출
        id?.let { loadVideo(it, 0) }

        // 스크롤 이벤트

        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if(mOffset != totalItemsCount)  loadMoreData(totalItemsCount)
            }
        }
        binding.rvVideo.addOnScrollListener(scrollListener)
        scrollListener.resetState()

    }

    private fun loadMoreData(offset: Int) {
        mOffset = offset
        id?.let { loadVideo(it,mOffset) }
    }

}