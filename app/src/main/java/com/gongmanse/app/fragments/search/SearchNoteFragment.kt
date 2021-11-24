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
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.activities.MainActivity
import com.gongmanse.app.activities.SearchResultActivity.Companion.listData
import com.gongmanse.app.adapter.search.SearchNoteRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentSearchNoteBinding
import com.gongmanse.app.fragments.sheet.SelectionSheetSpinner
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetSpinnerListener
import com.gongmanse.app.model.ActionType
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.utils.Constants
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


@Suppress("DEPRECATION")
class SearchNoteFragment(
    private var grade: String?,
    private val subjectId: Int?,
    private val keyword: String?
) : Fragment(), OnBottomSheetSpinnerListener {

    companion object {
        private val TAG = SearchNoteFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentSearchNoteBinding
    private lateinit var query: HashMap<String, String>
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mAdapter: SearchNoteRVAdapter
    private lateinit var bottomSheetSpinner: SelectionSheetSpinner
    private val type = 3
    private var mOffset = 0
    private var isLoading = false
    private var selectOrder: String = Constants.CONTENT_VALUE_LATEST
    private val linearLayoutManager = LinearLayoutManager(this.context)


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_search_note, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    fun scrollToTop() {
        binding.rvNote.smoothScrollToPosition(0)
    }

    private fun initView() {
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_note)
        initRVLayout()
        prepareData()
        passNoteData()
        liveScroll()

        binding.layoutHeader.tvSpinner.setOnClickListener {
            bottomSheetSpinner = SelectionSheetSpinner(this, binding.layoutHeader.tvSpinner.text.toString(), type)
            selectSpinner()
        }
    }

    private fun selectSpinner() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetSpinner.show(supportManager, bottomSheetSpinner.tag)
    }

    override fun selectionSpinner(value: String) {
        binding.layoutHeader.tvSpinner.text = value
        selectOrder = value
        mOffset = 0
        mAdapter.clear()
        initView()
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<VideoData>()
        mAdapter =  SearchNoteRVAdapter(this.context as Activity).apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.rvNote.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun listener(query: HashMap<String, String>) {
        if (grade == Constants.CONTENT_VALUE_ALL_GRADE) grade = ""
        var sortId: Int? = null

        when (selectOrder) {
            Constants.CONTENT_VALUE_AVG     -> sortId = Constants.CONTENT_RESPONSE_VALUE_AVG
            Constants.CONTENT_VALUE_LATEST  -> sortId = Constants.CONTENT_RESPONSE_VALUE_LATEST
            Constants.CONTENT_VALUE_NAME    -> sortId = Constants.CONTENT_RESPONSE_VALUE_NAME
            Constants.CONTENT_VALUE_SUBJECT -> sortId = Constants.CONTENT_RESPONSE_VALUE_SUBJECT
        }

        RetrofitClient.getService().getSearchNoteList(subjectId, grade, keyword, sortId, query[Constants.REQUEST_KEY_OFFSET]!!, Constants.LIMIT_DEFAULT ).enqueue( object : Callback<VideoList> {
            override fun onFailure(call: Call<VideoList>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
                binding.layoutHeader.totalNum = 0
            }

            override fun onResponse(call: Call<VideoList>, response: Response<VideoList>) {
                if (response.isSuccessful) {
                    response.body()?.apply {

                        setTotalNum(this.totalNum)

                        if (isLoading) mAdapter.removeLoading()

                        if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                            binding.setVariable(BR.item, this)
                            this.totalNum?.let { mAdapter.addTotal(it) }
                        } else {
                            this.data?.let {
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
        binding.rvNote.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        Log.d(TAG, "loadMoreData => $offset")
        if (isLoading) {
            binding.rvNote.post {
                mAdapter.addLoading()
            }
        }
        val handler = Handler()
        handler.postDelayed({
            mOffset = offset
            query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
            listener(query)
        }, Constants.ENDLESS_DELAY_VALUE)
    }

    private fun liveScroll(){
        listData.currentValue.observe(viewLifecycleOwner, { it1->
            mAdapter.clear()
            if(it1.size != 0){
                mAdapter.clear()
                mAdapter.addItems(it1)
            }
        })
        listData.currentPosition.observe(viewLifecycleOwner, { it2 ->
            Handler().postDelayed({
                binding.rvNote.smoothScrollToPosition(it2)
                MainActivity.listData.updateValue(ActionType.CLEAR, arrayListOf(),Constants.LIVE_DATA_DEFAULT_VALUE,Constants.LIVE_DATA_DEFAULT_VALUE)
            }, 1000L)
        })
    }

    private fun passNoteData(){
        var sortId  = 0
        if (grade == "모든 학년") grade = ""
        when (selectOrder) {
            Constants.CONTENT_VALUE_AVG     -> sortId = Constants.CONTENT_RESPONSE_VALUE_AVG
            Constants.CONTENT_VALUE_LATEST  -> sortId = Constants.CONTENT_RESPONSE_VALUE_LATEST
            Constants.CONTENT_VALUE_NAME    -> sortId = Constants.CONTENT_RESPONSE_VALUE_NAME
            Constants.CONTENT_VALUE_SUBJECT -> sortId = Constants.CONTENT_RESPONSE_VALUE_SUBJECT
        }
        mAdapter.addNoteData(grade,subjectId,keyword,sortId )
    }

    private fun setTotalNum(totalNum: Int?) {
        Log.e(TAG,"setTotalNum => $totalNum")
        if (totalNum != null ) binding.layoutHeader.totalNum = totalNum
        else binding.layoutHeader.totalNum = 0
    }

}