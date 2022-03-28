package com.gongmanse.app.fragments.home

import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.R
import com.gongmanse.app.activities.MainActivity.Companion.listData
import com.gongmanse.app.adapter.home.HomeSubjectRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentKemBinding
import com.gongmanse.app.fragments.sheet.SelectionSheet
import com.gongmanse.app.fragments.sheet.SelectionSheetSpinner
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetListener
import com.gongmanse.app.listeners.OnBottomSheetSpinnerListener
import com.gongmanse.app.model.ActionType
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.GBLog
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


@Suppress("DEPRECATION")
class HomeKEMFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener, OnBottomSheetListener , OnBottomSheetSpinnerListener {

    companion object {
        private val TAG = HomeKEMFragment::class.java.simpleName
        private const val CATEGORY_ID : Int = Constants.GRADE_SORT_ID_KEM
    }

    private val videoIds: MutableList<String> = mutableListOf()
    private lateinit var mRecyclerAdapter : HomeSubjectRVAdapter
    private lateinit var binding: FragmentKemBinding
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var bottomSheet: SelectionSheet
    private lateinit var bottomSheetSpinner: SelectionSheetSpinner
    private val type = 4// 정렬 Type
    private var page : Int = 0                                           // api 페이지
    private var isLoading = false
    private var selectView: String = Constants.CONTENT_VALUE_ALL         // 선택한 select 박스
    private var selectOrder: String = Constants.CONTENT_VALUE_LATEST        // 선택한 정렬
    private val linearLayoutManager = LinearLayoutManager(context)
    private var noteType: Int = Constants.NOTE_TYPE_KEM



    override fun onRefresh() {
        Log.d(TAG, "HomeKEMFragment:: onRefresh()")
        binding.refreshLayout.isRefreshing = false
        page = 0
        binding.rvVideo.removeAllViewsInLayout()
        mRecyclerAdapter.clear()
        videoIds.clear()
        initView()

    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_kem, container, false)
        initView()
        return binding.root
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
        setHeaderVisibility()
        setRVLayout()
        prepareData()

        //전체보기,시리즈보기,문제풀이
        binding.tvSelectBox.setOnClickListener {
            bottomSheet = SelectionSheet(this , binding.tvSelectBox.text.toString())
            selectBox()
        }
        //자동재생부분
        binding.tvVideoCount.swAutoPlay.setOnCheckedChangeListener { buttonView, isChecked ->
            mRecyclerAdapter.autoPlay(isChecked)
        }
        binding.refreshLayout.setOnRefreshListener(this)

        //정렬 방식
        binding.tvVideoCount.tvSpinner.setOnClickListener {
            bottomSheetSpinner = SelectionSheetSpinner(this , binding.tvVideoCount.tvSpinner.text.toString(), type)
            selectSpinner()
        }
        liveScroll()
//        binding.tvVideoCount.swAutoPlay.isChecked = true
    }
    private fun liveScroll(){
        listData.currentType.observe(viewLifecycleOwner, Observer {
            noteType = it
        })
        listData.currentValue.observe(viewLifecycleOwner, Observer { it1->
            if (noteType == Constants.NOTE_TYPE_KEM) {
                mRecyclerAdapter.clear()
                videoIds.clear()
                if(it1.size != 0){
                    mRecyclerAdapter.clear()
                    mRecyclerAdapter.addItems(it1)
                }
            }
        })
        listData.currentPosition.observe(viewLifecycleOwner, Observer {it2 ->
            if (noteType == Constants.NOTE_TYPE_KEM) {
                if( it2 != Constants.LIVE_DATA_DEFAULT_VALUE) {
                    Handler().postDelayed({
                        binding.rvVideo.smoothScrollToPosition(it2)
                        listData.updateValue(ActionType.CLEAR, arrayListOf(),Constants.LIVE_DATA_DEFAULT_VALUE,Constants.LIVE_DATA_DEFAULT_VALUE)
                    }, 1000L)
                }
            }
        })
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
            mRecyclerAdapter = HomeSubjectRVAdapter()
            binding.rvVideo.adapter = mRecyclerAdapter
        }
    }

    private fun selectBox() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheet.show(supportManager, bottomSheet.tag)
    }

    override fun selection(value: String) {
        binding.tvSelectBox.text = value
        selectView = value
        page = 0
        onRefresh()
    }

    private fun selectSpinner() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetSpinner.show(supportManager, bottomSheetSpinner.tag)
    }

    override fun selectionSpinner(value: String) {
        binding.tvVideoCount.tvSpinner.text = value
        selectOrder = value
        onRefresh()
    }

    private fun prepareData() {
        // 최초 호출
        Log.d(TAG, "prepareData...")
        when(selectView){
            Constants.CONTENT_VALUE_ALL ->{
                when(selectOrder){
                    Constants.CONTENT_VALUE_AVG ->loadVideoAll(page,Constants.SUBJECT_COMMENTARY_ALL,Constants.CONTENT_RESPONSE_VALUE_AVG)
                    Constants.CONTENT_VALUE_LATEST ->loadVideoAll(page,Constants.SUBJECT_COMMENTARY_ALL,Constants.CONTENT_RESPONSE_VALUE_LATEST)
                    Constants.CONTENT_VALUE_NAME -> loadVideoAll(page,Constants.SUBJECT_COMMENTARY_ALL,Constants.CONTENT_RESPONSE_VALUE_NAME)
                    Constants.CONTENT_VALUE_SUBJECT->loadVideoAll(page,Constants.SUBJECT_COMMENTARY_ALL,Constants.CONTENT_RESPONSE_VALUE_SUBJECT)
                }
            }
            Constants.CONTENT_VALUE_SERIES ->{
                loadVideoSeries(page)
            }
            Constants.CONTENT_VALUE_PROBLEM ->{
                loadVideoProblem(page,Constants.SUBJECT_COMMENTARY_PROBLEM)
            }
            Constants.CONTENT_VALUE_NOTE ->{
                loadVideoNote(page)
            }
        }
        // 스크롤 이벤트
        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if (!isLoading && page != totalItemsCount && totalItemsCount >= 20) {
                    isLoading = true
                    load(totalItemsCount)
                }
            }
        }
        // 스크롤 이벤트 초기화
        binding.rvVideo.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun load(totalItemsCount: Int) {
        if (isLoading) {
            binding.rvVideo.post {
                mRecyclerAdapter.addLoading()
            }
        }
        Handler().postDelayed({
            when(selectView){
                Constants.CONTENT_VALUE_ALL -> {
                    when(selectOrder){
                        Constants.CONTENT_VALUE_AVG -> if(page != totalItemsCount) loadVideoAll(totalItemsCount,Constants.SUBJECT_COMMENTARY_ALL,Constants.CONTENT_RESPONSE_VALUE_AVG)
                        Constants.CONTENT_VALUE_LATEST -> if(page != totalItemsCount) loadVideoAll(totalItemsCount,Constants.SUBJECT_COMMENTARY_ALL,Constants.CONTENT_RESPONSE_VALUE_LATEST)
                        Constants.CONTENT_VALUE_NAME -> if(page != totalItemsCount) loadVideoAll(totalItemsCount,Constants.SUBJECT_COMMENTARY_ALL,Constants.CONTENT_RESPONSE_VALUE_NAME)
                        Constants.CONTENT_VALUE_SUBJECT-> if(page != totalItemsCount) loadVideoAll(totalItemsCount,Constants.SUBJECT_COMMENTARY_ALL,Constants.CONTENT_RESPONSE_VALUE_SUBJECT)
                    }
                }
                Constants.CONTENT_VALUE_SERIES -> if(page != totalItemsCount) loadVideoSeries(totalItemsCount)
                Constants.CONTENT_VALUE_PROBLEM -> if(page != totalItemsCount) loadVideoProblem(totalItemsCount,Constants.SUBJECT_COMMENTARY_PROBLEM)
                Constants.CONTENT_VALUE_NOTE -> if(page != totalItemsCount) loadMoreData(totalItemsCount,loadVideoNote(totalItemsCount))
            }
        }, Constants.ENDLESS_DELAY_VALUE)
    }

    private fun loadMoreData(offset: Int ,function :Unit) {
        page = offset
    }

    private fun loadVideoAll(offset: Int,commentary : Int, sortId: Int) {
        Log.d(TAG, "loadVideoAll::")
        RetrofitClient.getService().getSubjectList(CATEGORY_ID, offset,commentary,sortId,Constants.LIMIT_DEFAULT).enqueue( object :
            Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                GBLog.e(TAG, "Failed API call with call : $call\nmessage : ${t.message},  cause : ${t.cause},  localizedMessage : ${t.localizedMessage}")
            }
            override fun onResponse(
                call: Call<VideoList>,
                response: Response<VideoList>
            ) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    page = offset
                    response.body()?.apply {
                        val temp = this.totalNum!!.toInt()
                        binding.tvVideoCount.totalNum = temp
                        this.data.let{
                            if (isLoading) {
                                mRecyclerAdapter.removeLoading()
                            }
                            binding.tvVideoCount.tvSpinner.visibility = View.VISIBLE
                            mRecyclerAdapter.addType(Constants.QUERY_TYPE_KEM)
                            mRecyclerAdapter.addSortId(sortId)
                            mRecyclerAdapter.addItems(it as List<VideoData>)
                            mRecyclerAdapter.addTotalAndType(temp,Constants.NOTE_TYPE_KEM)

                            // set recyclerView's videoIds
                            it.map { data ->
                                videoIds.add(data.id!!)
                            }
                            binding.rvVideo.videoIds = videoIds

                            isLoading = false
                        }
                    }
                }
            }
        })
    }
    private fun loadVideoProblem(offset: Int, commentary : Int) {
        Log.d(TAG, "loadVideoAll::")
        RetrofitClient.getService().getSubjectList(CATEGORY_ID, offset,commentary,Constants.CONTENT_RESPONSE_VALUE_SUBJECT,Constants.LIMIT_DEFAULT).enqueue( object :
            Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                GBLog.e(TAG, "Failed API call with call : $call\nexception : ${t.stackTrace}")
            }
            override fun onResponse(
                call: Call<VideoList>,
                response: Response<VideoList>
            ) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    page = offset
                    Log.d(TAG, "onResponse => $this")
                    Log.i(TAG, "onResponse Body => ${response.body()}")
                    response.body()?.apply {
                        this.data.let{
                            if (isLoading) {
                                mRecyclerAdapter.removeLoading()
                            }
                            binding.tvVideoCount.tvSpinner.visibility = View.GONE
                            mRecyclerAdapter.addType(Constants.QUERY_TYPE_KEM_PROBLEM)
                            mRecyclerAdapter.addItems(it as List<VideoData>)
                            mRecyclerAdapter.addSortId(Constants.CONTENT_RESPONSE_VALUE_SUBJECT)

                            // set recyclerView's videoIds
                            it.map { data ->
                                videoIds.add(data.id!!)
                            }
                            binding.rvVideo.videoIds = videoIds

                            isLoading = false
                        }
                        val temp = this.totalNum!!.toInt()
                        binding.tvVideoCount.totalNum = temp
                    }
                }
            }
        })
    }
    private fun loadVideoSeries(offset: Int) {
        Log.d(TAG, "loadVideoSeries::")
        RetrofitClient.getService().getSeries(CATEGORY_ID, offset).enqueue( object :
            Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                GBLog.e(TAG, "Failed API call with call : $call\nexception : ${t.stackTrace}")
            }
            override fun onResponse(
                call: Call<VideoList>,
                response: Response<VideoList>
            ) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    page = offset
                    Log.d(TAG, "onResponse => $this")
                    Log.i(TAG, "onResponse Body => ${response.body()}")
                    response.body()?.apply {
                        this.data.let{
                            if (isLoading) {
                                mRecyclerAdapter.removeLoading()
                            }
                            mRecyclerAdapter.addType(Constants.QUERY_TYPE_SERIES)
                            mRecyclerAdapter.addItems(it as List<VideoData>)
                            isLoading = false
                            val temp: String = this.totalNum.toString()
                            temp.let{
                                val totalNum = temp.toInt()
                                Log.d("item check" , "${totalNum}")
                                binding.tvVideoCount.totalNum = totalNum
                            }
                        }

                    }
                }
            }
        })
    }
    private fun loadVideoNote(offset: Int) {
        Log.d(TAG, "loadVideoNote")
        RetrofitClient.getService().getNoteList(CATEGORY_ID, offset).enqueue( object :
            Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                GBLog.e(TAG, "Failed API call with call : $call\nexception : ${t.stackTrace}")
            }
            override fun onResponse(
                call: Call<VideoList>,
                response: Response<VideoList>
            ) {
                if (response.isSuccessful) {
                    page = offset
                    Log.d(TAG, "onResponse => $this")
                    Log.i(TAG, "onResponse Body => ${response.body()}")
                    response.body()?.apply {
                        this.data.let{
                            if (isLoading) {
                                mRecyclerAdapter.removeLoading()
                            }
                            mRecyclerAdapter.addType(Constants.QUERY_TYPE_NOTE)
                            Log.d("테스트" , "$offset")
                            Log.d("테스트2" , "$it")
                            mRecyclerAdapter.addItems(it as List<VideoData>)
                            isLoading = false
                            val temp: String = this.totalNum.toString()
                            temp.let{
                                val totalNum = temp.toInt()
                                binding.tvVideoCount.totalNum = totalNum
                            }
                        }

                    }
                } else {
                    Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                }
            }
        })
    }

    private fun setHeaderVisibility(){
        binding.apply {
            when(tvSelectBox.text){
                Constants.CONTENT_VALUE_ALL -> {
                    tvVideoCount.tvSpinner.visibility = View.VISIBLE
                    tvVideoCount.swAutoPlay.visibility = View.VISIBLE
                }
                Constants.CONTENT_VALUE_SERIES->{
                    tvVideoCount.tvSpinner.visibility = View.GONE
                    tvVideoCount.swAutoPlay.visibility = View.GONE
                }
                Constants.CONTENT_VALUE_PROBLEM ->{
                    tvVideoCount.tvSpinner.visibility = View.GONE
                    tvVideoCount.swAutoPlay.visibility = View.VISIBLE
                }
                Constants.CONTENT_VALUE_NOTE ->{
                    tvVideoCount.tvSpinner.visibility = View.GONE
                    tvVideoCount.swAutoPlay.visibility = View.GONE
                }
            }
        }
    }

}
