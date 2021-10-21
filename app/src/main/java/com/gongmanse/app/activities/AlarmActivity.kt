package com.gongmanse.app.activities

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.AlarmRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityAlarmBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.Alarm
import com.gongmanse.app.model.AlarmData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class AlarmActivity : AppCompatActivity() {

    private lateinit var binding: ActivityAlarmBinding
    private lateinit var query: HashMap<String, String>
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mAdapter: AlarmRVAdapter
    private val linearLayoutManager = LinearLayoutManager(this)
    private var mOffset = 0
    private var isLoading = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAlarmBinding.inflate(layoutInflater)
        setContentView(binding.root)
        bindUI()
    }

    private fun bindUI() {
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_ALARM
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_alarm_list)
        binding.layoutToolbar.btnClose.setOnClickListener {
            onBackPressed()
            finish()
        }
        initRVLayout()
        prepareData()
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<AlarmData>()
        mAdapter = AlarmRVAdapter().apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.rvAlarm.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
            addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL))
        }
    }

    private fun listener(query: HashMap<String, String>) {
        RetrofitClient.getService().getAlarmList(Preferences.token, query[Constants.REQUEST_KEY_OFFSET]!!, query[Constants.REQUEST_KEY_LIMIT]!!).enqueue(object: Callback<Alarm> {
            override fun onFailure(call: Call<Alarm>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Alarm>, response: Response<Alarm>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.d(TAG, "onResponse => $this")
                        if (isLoading) {
                            mAdapter.removeLoading()
                        }
                        if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                            binding.setVariable(BR.item, this)
                        } else {
                            this.data?.let {
                                mAdapter.addItems(it)
                            }
                        }
                        isLoading = false
                    }
                }
            }
        })
    }

    private fun prepareData() {
        // 최초 호출
        Log.d(TAG, "prepareData...")
        query = hashMapOf(Constants.REQUEST_KEY_OFFSET to Constants.OFFSET_DEFAULT, Constants.REQUEST_KEY_LIMIT to Constants.LIMIT_DEFAULT)
        listener(query)

        // 스크롤 이벤트
        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                if (!isLoading && mOffset != totalItemsCount && totalItemsCount >= 20) {
                    isLoading = true
                    loadMoreData(totalItemsCount)
                }
            }
        }

        // 스크롤 이벤트 초기화
        binding.rvAlarm.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        // 추가 호출
        Log.d(TAG, "loadMoreData => offset = $offset")
        if (isLoading) {
            mAdapter.addLoading()
        }
        Handler(Looper.getMainLooper()).postDelayed({
            mOffset = offset
            query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
            listener(query)
        }, Constants.ENDLESS_DELAY_VALUE)
    }

    companion object {
        private val TAG = AlarmActivity::class.java.simpleName
    }

}