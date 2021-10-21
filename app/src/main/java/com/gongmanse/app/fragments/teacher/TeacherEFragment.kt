package com.gongmanse.app.fragments.teacher

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.gongmanse.app.R
import com.gongmanse.app.adapter.teacher.TeacherERvAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentTeacherEBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.Teacher
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.lang.reflect.Type


class TeacherEFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = TeacherEFragment::class.java.simpleName
        private const val ELEMENTARY = "초등"
        private const val FIRST_OFFSET = 0
    }

    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var binding: FragmentTeacherEBinding
    private val mRecyclerAdapter by lazy { TeacherERvAdapter() }
    private val linearLayoutManager = LinearLayoutManager(context)
    private var mOffset : Int = 0


    override fun onRefresh() {
        Log.d(TAG, "TeacherEFragment:: onRefresh()")
        binding.refreshLayout.isRefreshing = false
        mOffset = 0
        mRecyclerAdapter.clear()
        initView()
    }


    override fun onCreateView(inflater: LayoutInflater,container: ViewGroup?,savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_teacher_e, container, false)
        initView()
        return binding.root
    }

    fun scrollToTop(){
        binding.rvVideo.smoothScrollToPosition(0)
    }

    private fun initView() {
        binding.refreshLayout.setOnRefreshListener(this)
        binding.refreshLayout.isRefreshing = false
        prepareData()
        setRVLayout()
    }

    private fun setRVLayout() {
        binding.rvVideo.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            val linearLayout = LinearLayoutManager(context)
            linearLayout.orientation = LinearLayoutManager.VERTICAL
            layoutManager = linearLayout
        }
        if (binding.rvVideo.adapter == null) {
            mRecyclerAdapter.setHasStableIds(true)
            binding.rvVideo.adapter = mRecyclerAdapter
        }
    }
    private fun loadVideo(offset : Int){
        RetrofitClient.getService().getTeacherList(ELEMENTARY,offset).enqueue( object :
            Callback<Map<String, Any>> {
            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, Any>>,response: Response<Map<String, Any>>
            ) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    Log.d(TAG, "onResponse => $this")
                    Log.i(TAG, "onResponse Body => ${response.body()}")
                    response.body()?.let {
                        val type: Type = object : TypeToken<List<Teacher>>() {}.type
                        val jsonResult = Gson().toJson(it["data"])
                        val item = Gson().fromJson<List<Teacher>>(jsonResult, type)
                        mRecyclerAdapter.addItems(item)

                    }
                }
            }
        })
    }

    private fun prepareData() {
        // 최초 호출
        loadVideo(mOffset)

        // 스크롤 이벤트
        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if(mOffset != totalItemsCount)  loadMoreData(totalItemsCount)
            }
        }

        // 스크롤 이벤트 초기화
        scrollClear()
    }

    private fun scrollClear(){
        binding.rvVideo.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        mOffset = offset
        loadVideo(mOffset)
    }

}