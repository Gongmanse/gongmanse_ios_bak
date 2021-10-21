package com.gongmanse.app.activities

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.core.view.marginTop
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.R
import com.gongmanse.app.adapter.teacher.TeacherListRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityTeacherListBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.Teacher
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.utils.Constants
import kotlinx.android.synthetic.main.activity_teacher_detail.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class TeacherListActivity : AppCompatActivity() , SwipeRefreshLayout.OnRefreshListener {

    private lateinit var binding: ActivityTeacherListBinding

    companion object {
        private val TAG = TeacherListActivity::class.java.simpleName

    }

    private lateinit var mRecyclerAdapter : TeacherListRVAdapter
    private var id : Int? = null
    private lateinit var scrollListener: EndlessRVScrollListener
    private val linearLayoutManager = LinearLayoutManager(this)
    private var mOffset : Int = 0
    private var grade = ""


    override fun onRefresh() {
        Log.d(TAG, "KEMFragment:: onRefresh()")
        refresh_layout.isRefreshing = false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_teacher_list)
        binding.layoutToolbar.btnClose.setOnClickListener { onBackPressed()  }
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_TEACHER
        binding.tvVideoCount.swAutoPlay.visibility = View.GONE


        loadData()
        initView()

    }

    private fun initView() {
        prepareData()
        refresh_layout.setOnRefreshListener(this)
        setRVLayout()
    }

    private fun loadData() {
        if (intent.hasExtra("teacher")) {
            intent.getSerializableExtra("teacher").let {
                val teacherData = it as Teacher
                binding.layoutDetailHeader.data = teacherData
                binding.layoutDetailHeader.tvTitle.visibility = View.GONE
                binding.layoutDetailHeader.tvTeacherName.textSize = 20.0F
                binding.layoutDetailHeader.tvTeacherName.marginTop
                id = teacherData.id
                grade = teacherData.grade
            }
            intent.getStringExtra("grade").let{
                if (it != null) {
                    grade = it
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
        mRecyclerAdapter =TeacherListRVAdapter(grade)
            binding.rvVideo.adapter = mRecyclerAdapter
    }

    private fun loadVideo(id : Int,offset: Int ) {
        RetrofitClient.getService().getTeacherSeriesList(id, grade, offset).enqueue( object :
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
                            val itemList = it as List<VideoData>
                            mRecyclerAdapter.addItems(itemList)
                        }
                        val temp: String = this!!.totalNum.toString()
                        temp.let{
                            val totalNum = temp.toInt()
                            Log.d("item" , "${totalNum}")
                            if(totalNum != 0){
                                binding.tvVideoCount.totalNum = totalNum
                            }
                        }
                    }
                }
            }
        })
    }

    private fun prepareData() {
        // 최초 호출
        id?.let { loadVideo(it, mOffset) }

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