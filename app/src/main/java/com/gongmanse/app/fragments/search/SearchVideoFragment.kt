package com.gongmanse.app.fragments.search

import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.activities.SearchResultActivity
import com.gongmanse.app.adapter.search.SearchVideoLoadingRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentSearchVideoBinding
import com.gongmanse.app.fragments.sheet.SelectionSheetSpinner
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetSpinnerListener
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.utils.Constants
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


@Suppress("DEPRECATION")
class SearchVideoFragment(
    private var grade: String?,
    private val subjectId: Int?,
    private val keyword: String?,
    private var from: Boolean
) : Fragment(), OnBottomSheetSpinnerListener  {

    companion object {
        private val TAG = SearchVideoFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentSearchVideoBinding
    private lateinit var query: HashMap<String, String>
    private lateinit var bottomQuery: HashMap<String, Any?>
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mAdapter: SearchVideoLoadingRVAdapter
    private lateinit var bottomSheetSpinner: SelectionSheetSpinner
    private val type = 7                                                // 타입: 관련순
    private var mOffset = 0
    private var isLoading = false
    private var selectOrder: String = Constants.CONTENT_VALUE_RELEVANCE
    private val linearLayoutManager = LinearLayoutManager(this.context)


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_search_video, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    fun scrollToTop(){
        binding.rvVideo.smoothScrollToPosition(0)
    }

    private fun getBottomVideoInfo(){
        bottomQuery = (activity as SearchResultActivity).returnVideoInfo()
        if(bottomQuery[Constants.EXTRA_KEY_VIDEO_ID] != null){
            mAdapter.videoBottomVideoInfo(bottomQuery)
        }
    }

    private fun initView() {
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_progress)
        initRVLayout()
        prepareData()
        getBottomVideoInfo()

        binding.layoutVideoCount.swAutoPlay.setOnCheckedChangeListener { buttonView, isChecked -> mAdapter.autoPlay(isChecked) }
        binding.layoutVideoCount.tvSpinner.setOnClickListener {
            bottomSheetSpinner = SelectionSheetSpinner(this, binding.layoutVideoCount.tvSpinner.text.toString(), type)
            selectSpinner()
        }
        binding.layoutVideoCount.swAutoPlay.isChecked = true
    }

    private fun selectSpinner() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetSpinner.show(supportManager, bottomSheetSpinner.tag)
    }

    override fun selectionSpinner(value: String) {
        binding.layoutVideoCount.tvSpinner.text = value
        selectOrder = value
        mOffset = 0
        mAdapter.clear()
        initView()
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<VideoData>()
        mAdapter =  SearchVideoLoadingRVAdapter(this.context as Activity, from).apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.rvVideo.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun listener(query: HashMap<String, String>) {
        if (grade == "모든 학년") grade = ""
        var sortId: Int? = null

        when (selectOrder) {
            Constants.CONTENT_VALUE_AVG       -> sortId = Constants.CONTENT_RESPONSE_VALUE_AVG
            Constants.CONTENT_VALUE_LATEST    -> sortId = Constants.CONTENT_RESPONSE_VALUE_LATEST
            Constants.CONTENT_VALUE_NAME      -> sortId = Constants.CONTENT_RESPONSE_VALUE_NAME
            Constants.CONTENT_VALUE_SUBJECT   -> sortId = Constants.CONTENT_RESPONSE_VALUE_SUBJECT
            Constants.CONTENT_VALUE_RELEVANCE -> sortId = Constants.CONTENT_RESPONSE_VALUE_RELEVANCE
        }

        RetrofitClient.getService().getSearchVideoList(subjectId, grade, sortId, keyword, query[Constants.REQUEST_KEY_OFFSET]!!, Constants.LIMIT_DEFAULT).enqueue(object : Callback<VideoList> {
                override fun onFailure(call: Call<VideoList>, t: Throwable) {
                    Log.e(TAG, "Failed API call with call : $call\nexception : $t")
                    binding.layoutVideoCount.totalNum = 0
                }

                override fun onResponse(call: Call<VideoList>, response: Response<VideoList>) {
                    if (response.isSuccessful) {
                        response.body()?.apply {

                            setTotalNum(this.totalNum)

                            if (isLoading) mAdapter.removeLoading()

                            if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                                mAdapter.searchInfo(sortId, subjectId, grade, keyword, Constants.OFFSET_DEFAULT)
                                binding.setVariable(BR.item, this)
                            } else {
                                this.data?.let {
                                    mAdapter.searchInfo(sortId, subjectId, grade, keyword, query[Constants.REQUEST_KEY_OFFSET])
                                    mAdapter.addItems(it)
                                }
                            }
                            isLoading = false
                        }
                    }
                    else Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
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
        Log.d(TAG, "loadMoreData => $offset")
        if (isLoading) mAdapter.addLoading()
        val handler = Handler()
        handler.postDelayed({
            mOffset = offset
            query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
            listener(query)
        }, Constants.ENDLESS_DELAY_VALUE)
    }

    private fun setTotalNum(totalNum: Int?) {
        if (totalNum != null ) binding.layoutVideoCount.totalNum = totalNum
        else binding.layoutVideoCount.totalNum = 0
    }

}
