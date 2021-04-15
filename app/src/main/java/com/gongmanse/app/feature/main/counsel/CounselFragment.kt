package com.gongmanse.app.feature.main.counsel

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
import com.gongmanse.app.R
import com.gongmanse.app.databinding.FragmentCounselBinding
import com.gongmanse.app.feature.main.home.tabs.SelectionSheetSpinner
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.EndlessRVScrollListener
import com.gongmanse.app.utils.Preferences
import com.gongmanse.app.utils.listeners.OnBottomSheetSpinnerListener


@Suppress("DEPRECATION")
class CounselFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener,
    OnBottomSheetSpinnerListener {

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
    private var selectOrder: String = Constants.SelectValue.SORT_LATEST
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


    private fun initView() {
        binding.refreshLayout.setOnRefreshListener(this)
//        initRVLayout()
        prepareData()

        binding.btnCounselPlus.setOnClickListener {
            if(Preferences.token.isEmpty()){
                loginCheck()
            }else{
//                startActivity(intentFor<CounselCreateActivity>().singleTop())
            }
        }

        binding.layoutHeader.tvSpinner.setOnClickListener {
            bottomSheetSpinner = SelectionSheetSpinner(this, binding.layoutHeader.tvSpinner.text.toString(), type)
            selectSpinner()
        }
    }

    private fun loginCheck(){
//        alert(title = getString(R.string.content_button_login), message = getString(R.string.content_text_need_login)) {
//            positiveButton(getString(R.string.content_button_positive)) {
//                it.dismiss()
//                (activity as MainActivity).openDrawer()
//
//            }
//            negativeButton(getString(R.string.content_button_negative)) {
//                it.dismiss()
//            }
//        }.show()
    }


    private fun selectSpinner() {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetSpinner.show(supportManager, bottomSheetSpinner.tag)    }

//    private fun initRVLayout() {
//        val items = ObservableArrayList<CounselData>()
//        mAdapter = CounselListAdapter().apply { addItems(items) }
//        binding.rvCounselList.apply {
//            adapter = mAdapter
//            layoutManager = linearLayoutManager
//        }
//    }
//
//    when(selectOrder){
//        Constants.SelectValue.SORT_AVG      -> viewModel.loadVideo( Constants.SubjectValue.ETC, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_AVG, Constants.SubjectType.DEFAULT)
//        Constants.SelectValue.SORT_LATEST   -> viewModel.loadVideo( Constants.SubjectValue.ETC, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_LATEST, Constants.SubjectType.DEFAULT)
//        Constants.SelectValue.SORT_NAME     -> viewModel.loadVideo( Constants.SubjectValue.ETC, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_NAME, Constants.SubjectType.DEFAULT)
//        Constants.SelectValue.SORT_SUBJECT  -> viewModel.loadVideo( Constants.SubjectValue.ETC, mOffset, Constants.DefaultValue.LIMIT_INT, Constants.SelectValue.SORT_VALUE_SUBJECT, Constants.SubjectType.DEFAULT)
//    }

    private fun listener(query: HashMap<String, String>){
        var sortId: Int? = null
        when (selectOrder) {
            Constants.SelectValue.SORT_AVG  -> Constants.SelectValue.SORT_VALUE_AVG
            Constants.SelectValue.SORT_LATEST  -> Constants.SelectValue.SORT_VALUE_LATEST
            Constants.SelectValue.SORT_SUBJECT -> Constants.SelectValue.SORT_VALUE_SUBJECT
        }
    }

    private fun prepareData() {
//        listener(query)

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
        }, Constants.Delay.VALUE_OF_ENDLESS)
    }

    private fun setTotalNum(totalNum: Int?) {
        if (totalNum != null ) binding.layoutHeader.totalNum = totalNum
        else binding.layoutHeader.totalNum = 0
    }

    private fun isLoadingCheck(loading: Boolean) {
        Log.d(TAG,"loading : $loading")
        if (isLoading) mAdapter.removeLoading()
    }

    override fun selectedSortSpinnerValue(value: String) {
        binding.layoutHeader.tvSpinner.text = value
        selectOrder = value
        mAdapter.clear()
        initView()
    }


}