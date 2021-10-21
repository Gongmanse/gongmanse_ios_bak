package com.gongmanse.app.fragments.customer

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.activities.LoginActivity
import com.gongmanse.app.activities.customer.AddOneToOneActivity
import com.gongmanse.app.adapter.OneToOneRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentOneToOneBinding
import com.gongmanse.app.fragments.notice.NoticeEventFragment
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.Event
import com.gongmanse.app.model.OneToOne
import com.gongmanse.app.model.OneToOneData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.support.v4.alert
import org.jetbrains.anko.support.v4.intentFor
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class OneToOneFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener {

    companion object {
        private var TAG = OneToOneFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentOneToOneBinding
    private lateinit var mAdapter: OneToOneRVAdapter
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var query: HashMap<String, String>
    private val linearLayoutManager = LinearLayoutManager(context)
    private var mOffset = 0

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_one_to_one, container, false)
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

    override fun onResume() {
        super.onResume()
        mAdapter.clear()
        prepareData()

    }

    private fun initView() {
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_question_str)
        binding.layoutRefresh.setOnRefreshListener(this)
        binding.btnAddQna.setOnClickListener {
            if (Preferences.token.isEmpty()) {
                alert(title = null, message = getString(R.string.content_text_toast_login)) {
                    positiveButton(getString(R.string.content_button_positive)) {
                        it.dismiss()
                        startActivity(intentFor<LoginActivity>().singleTop())
                    }
                    negativeButton(getString(R.string.content_button_negative)) {it.dismiss()}
                }.show()
            } else startActivity(intentFor<AddOneToOneActivity>().singleTop())
        }
        initRVLayout()
        prepareData()
    }

    private fun initRVLayout() {
        Log.d(TAG, "initRVLayout()")
        val items = ObservableArrayList<OneToOneData>()
        mAdapter = OneToOneRVAdapter().apply {
            addItems(items)
        }
        binding.rvOneToOne.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun listener(query: HashMap<String, String>) {
        Log.d(TAG, "loadOnToOnList()")
        RetrofitClient.getService().getOneToOneList(Preferences.token).enqueue( object : Callback<OneToOne> {
            override fun onFailure(call: Call<OneToOne>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<OneToOne>, response: Response<OneToOne>) {
                if (response.isSuccessful) {
                    Log.i(TAG, "onResponseBody => ${response.body()}")
                    response.body()?.apply {
                        if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                            binding.setVariable(BR.item, this)
                        } else {
                            this.data.let { mAdapter.addItems(it) }
                        }
                    }

                } else Log.e(TAG, "Failed ResponseCode => ${response.code()}")
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
                if (mOffset != totalItemsCount && totalItemsCount >= 20) loadMoreData(totalItemsCount)
            }
        }

        // 스크롤 이벤트 초기화
        binding.rvOneToOne.addOnScrollListener(scrollListener)
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