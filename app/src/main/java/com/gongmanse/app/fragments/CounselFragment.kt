package com.gongmanse.app.fragments

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
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.activities.CounselCreateActivity
import com.gongmanse.app.activities.MainActivity
import com.gongmanse.app.adapter.counsel.CounselListAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentCounselBinding
import com.gongmanse.app.fragments.search.SearchCounselFragment
import com.gongmanse.app.fragments.sheet.SelectionSheetSpinner
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetSpinnerListener
import com.gongmanse.app.model.Counsel
import com.gongmanse.app.model.CounselData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.support.v4.alert
import org.jetbrains.anko.support.v4.intentFor
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

@Suppress("DEPRECATION")
class CounselFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener, OnBottomSheetSpinnerListener {

    companion object {
        private val TAG = CounselFragment::class.java.simpleName
    }
    
    private lateinit var binding: FragmentCounselBinding
    private lateinit var query: HashMap<String, String>
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mAdapter: CounselListAdapter
    private lateinit var bottomSheetSpinner: SelectionSheetSpinner
    private val type = 6
    private var mOffset = 0
    private var isLoading = false
    private var selectOrder: String = Constants.CONTENT_VALUE_LATEST
    private val linearLayoutManager = LinearLayoutManager(this.context)

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater,R.layout.fragment_counsel,container,false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onRefresh() {
        binding.refreshLayout.isRefreshing = false
        mAdapter.clear()
        initView()
    }

    override fun onResume() {
        super.onResume()
        onRefresh()
    }

    private fun initView() {
        binding.refreshLayout.setOnRefreshListener(this)
        initRVLayout()
        prepareData()

        binding.btnCounselPlus.setOnClickListener {
            if(Preferences.token.isEmpty()){
                loginCheck()
            }else{
                startActivity(intentFor<CounselCreateActivity>().singleTop())
            }
        }

        binding.layoutHeader.tvSpinner.setOnClickListener {
            bottomSheetSpinner = SelectionSheetSpinner(this, binding.layoutHeader.tvSpinner.text.toString(), type)
            selectSpinner()
        }
    }

    private fun loginCheck(){
        alert(title = getString(R.string.content_button_login), message = getString(R.string.content_text_need_login)) {
            positiveButton(getString(R.string.content_button_positive)) {
                it.dismiss()
                (activity as MainActivity).openDrawer()
            }
            negativeButton(getString(R.string.content_button_negative)) {
                it.dismiss()
            }
        }.show()
    }


    private fun selectSpinner() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetSpinner.show(supportManager, bottomSheetSpinner.tag)    }

    override fun selectionSpinner(value: String) {
        binding.layoutHeader.tvSpinner.text = value
        selectOrder = value
        mAdapter.clear()
        initView()
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<CounselData>()
        mAdapter = CounselListAdapter().apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.rvCounselList.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
        }
    }

    private fun listener(query: HashMap<String, String>){
        var sortId: Int? = null
        when (selectOrder) {
            Constants.CONTENT_VALUE_LATEST -> sortId = Constants.CONTENT_RESPONSE_VALUE_LATEST
            Constants.CONTENT_VALUE_VIEWS  -> sortId = Constants.CONTENT_RESPONSE_VALUE_VIEWS
            Constants.CONTENT_VALUE_ANSWER -> sortId = Constants.CONTENT_RESPONSE_VALUE_ANSWER
        }
        RetrofitClient.getService().getCounselList(sortId, query[Constants.REQUEST_KEY_OFFSET]!!, Constants.LIMIT_DEFAULT).enqueue(object:
            Callback<Counsel> {
            override fun onFailure(call: Call<Counsel>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                binding.layoutHeader.totalNum = 0
            }

            override fun onResponse(call: Call<Counsel>, response: Response<Counsel>) {
                if (!response.isSuccessful) Log.d(TAG,"Failed API code : ${response.code()}\n message : ${response.message()}"
                )
                if (response.isSuccessful) {
                    response.body()?.apply {
                        if (query[Constants.REQUEST_KEY_OFFSET] == Constants.OFFSET_DEFAULT) {
                            setTotalNum(this.totalNum?.toInt())
                            isLoadingCheck(isLoading)
                            binding.setVariable(BR.item, this)
                        } else {
                            setTotalNum(this.totalNum?.toInt())
                            this.data?.let {
                                isLoadingCheck(isLoading)
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
        binding.rvCounselList.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        mOffset = offset
        if (isLoading) mAdapter.addLoading()
        val handler = Handler()
        handler.postDelayed({
            mOffset = offset
            query[Constants.REQUEST_KEY_OFFSET] = offset.toString()
            listener(query)
        }, Constants.ENDLESS_DELAY_VALUE)
    }

    private fun setTotalNum(totalNum: Int?) {
        if (totalNum != null ) binding.layoutHeader.totalNum = totalNum
        else binding.layoutHeader.totalNum = 0
    }

    private fun isLoadingCheck(loading: Boolean) {
        Log.d(TAG,"loading : $loading")
        if (isLoading) mAdapter.removeLoading()
    }


}