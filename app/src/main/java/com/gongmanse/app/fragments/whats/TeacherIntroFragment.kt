package com.gongmanse.app.fragments.whats

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
import com.gongmanse.app.adapter.TeacherIntroRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentTeacherIntroBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.Teacher
import com.gongmanse.app.utils.Constants
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.lang.reflect.Type

class TeacherIntroFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private val TAG = TeacherIntroFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentTeacherIntroBinding
    private lateinit var mAdapter: TeacherIntroRVAdapter
    private lateinit var query: HashMap<String, String>
    private lateinit var scrollListener: EndlessRVScrollListener
    private val linearLayoutManager = LinearLayoutManager(context)
    private var mOffset = 0


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_teacher_intro, container, false)
        return binding.root
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

    private fun listener(query: HashMap<String, String>) {
        RetrofitClient.getService().getTeacherList("",   query[Constants.REQUEST_KEY_OFFSET]!!.toInt()).enqueue( object :
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
                        mAdapter.addItems(item)
                        Log.i(TAG,"공만세란? 강사소개 => $item")
                    }
                }
            }
        })
    }

    fun scrollToTop() = binding.rvIntroTeacher.smoothScrollToPosition(0)


    private fun initView() {
        initRVLayout()
        prepareData()
    }

    private fun initRVLayout() {
        binding.rvIntroTeacher.apply {
            setHasFixedSize(true)
            mAdapter = TeacherIntroRVAdapter()
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
        if (binding.rvIntroTeacher.adapter == null) binding.rvIntroTeacher.adapter = mAdapter
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
        binding.rvIntroTeacher.addOnScrollListener(scrollListener)
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