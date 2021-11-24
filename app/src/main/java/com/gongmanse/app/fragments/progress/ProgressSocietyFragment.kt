package com.gongmanse.app.fragments.progress

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
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.adapter.progress.ProgressRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentProgressSocietyBinding
import com.gongmanse.app.fragments.sheet.SelectionSheetGrade
import com.gongmanse.app.fragments.sheet.SelectionSheetUnitTitle
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import com.gongmanse.app.model.Progress
import com.gongmanse.app.model.ProgressData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.support.v4.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


@Suppress("DEPRECATION")
class ProgressSocietyFragment : Fragment(), SwipeRefreshLayout.OnRefreshListener,OnBottomSheetProgressListener {

    companion object {
        private val TAG = ProgressSocietyFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentProgressSocietyBinding
    private lateinit var bottomSheetGrade: SelectionSheetGrade
    private lateinit var bottomSheetUnit: SelectionSheetUnitTitle
    private lateinit var scrollListener: EndlessRVScrollListener
    private lateinit var mAdapter : ProgressRVAdapter
    private lateinit var query: HashMap<String, String>
    private var grade: String? = Constants.CONTENT_VALUE_ALL_GRADE
    private var gradeTitle: String? = null
    private var jindoTitle: String? = null
    private var gradeNum: Int? = 0
    private var mOffset = 0
    private var isLoading = false
    private val linearLayoutManager = LinearLayoutManager(context)

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_progress_society, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onRefresh() {
        binding.layoutRefresh.isRefreshing = false
        mOffset = 0
        mAdapter.clear()
        prepareData()
    }

    override fun onSelectionGrade(
        key: String,
        grades: String?,
        grade_title: String?,
        grade_num: Int?
    ) {
        if (key == "selectionGrade") binding.tvSelectGrade.text = grade_title
        binding.tvSelectUnit.text = Constants.CONTENT_VALUE_ALL_UNIT

        grade = grades
        gradeTitle = grade_title
        gradeNum = grade_num
        bottomSheetGrade.dismiss()
        mAdapter.clear()
        if (key.isNotEmpty()) {
            onRefresh()
        }
    }

    override fun onSelectionUnit(key: String, id: Int?, jindo_title: String) {
        if (key == "selectionUnit") {
            jindoTitle = jindo_title
            binding.tvSelectUnit.text = jindo_title
        }
        bottomSheetUnit.dismiss()
        mAdapter.clear()
        if (id != null) {
            getSingleJindo(id)
        } else {
            listener(query)
        }

    }

    fun scrollToTop() = binding.rvSocietyList.smoothScrollToPosition(0)

    private fun initView() {
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_progress)
        binding.layoutRefresh.setOnRefreshListener(this)
        selectedSetting()
        initRVLayout()
        prepareData()

        binding.layoutGrade.setOnClickListener {
            bottomSheetGrade = SelectionSheetGrade(this, gradeTitle)
            supportManager(bottomSheetGrade)
        }

        binding.layoutUnit.setOnClickListener {
            if (grade.isNullOrEmpty()) toast("학년을 선택해 주세요.")
            else {
                jindoTitle = binding.tvSelectUnit.text.toString()
                bottomSheetUnit = SelectionSheetUnitTitle(this, Constants.GRADE_SORT_ID_SOCIETY, grade, jindoTitle, gradeNum)
                supportManager(bottomSheetUnit)
            }
        }
    }

    // 설정: 과목 및 연결
    private fun selectedSetting() {
        Log.d(TAG, "SelectedSetting()")
        if (Preferences.grade.isNotEmpty()) {
            checkGradeNumber(Preferences.grade)
            gradeTitle = Preferences.grade
            binding.tvSelectGrade.text = Preferences.grade
            binding.tvSelectUnit.text  = Constants.CONTENT_VALUE_ALL_UNIT
        }
        else {
            grade = null
            gradeTitle = Constants.CONTENT_VALUE_ALL_GRADE
            binding.tvSelectGrade.text = Constants.CONTENT_VALUE_ALL_GRADE
            binding.tvSelectUnit.text  = Constants.CONTENT_VALUE_ALL_UNIT
        }
    }

    private fun checkGradeNumber(value: String) {
        when(value) {
            // 초등
            Constants.CONTENT_VALUE_ELEMENTARY_first  -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, Constants.CONTENT_VALUE_GRADE_NUM_FIRST)}
            Constants.CONTENT_VALUE_ELEMENTARY_second -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, Constants.CONTENT_VALUE_GRADE_NUM_SECOND)}
            Constants.CONTENT_VALUE_ELEMENTARY_third  -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, Constants.CONTENT_VALUE_GRADE_NUM_THIRD)}
            Constants.CONTENT_VALUE_ELEMENTARY_fourth -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, Constants.CONTENT_VALUE_GRADE_NUM_FOURTH)}
            Constants.CONTENT_VALUE_ELEMENTARY_fifth  -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, Constants.CONTENT_VALUE_GRADE_NUM_FIFTH)}
            Constants.CONTENT_VALUE_ELEMENTARY_sixth  -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, Constants.CONTENT_VALUE_GRADE_NUM_SIXTH)}
            // 중등
            Constants.CONTENT_VALUE_MIDDLE_first      -> { updateGrade(Constants.CONTENT_VALUE_MIDDLE, Constants.CONTENT_VALUE_GRADE_NUM_FIRST)}
            Constants.CONTENT_VALUE_MIDDLE_second     -> { updateGrade(Constants.CONTENT_VALUE_MIDDLE, Constants.CONTENT_VALUE_GRADE_NUM_SECOND)}
            Constants.CONTENT_VALUE_MIDDLE_third      -> { updateGrade(Constants.CONTENT_VALUE_MIDDLE, Constants.CONTENT_VALUE_GRADE_NUM_THIRD)}

            // 고등
            Constants.CONTENT_VALUE_HIGH_first        -> { updateGrade(Constants.CONTENT_VALUE_HIGH, Constants.CONTENT_VALUE_GRADE_NUM_FIRST)}
            Constants.CONTENT_VALUE_HIGH_second       -> { updateGrade(Constants.CONTENT_VALUE_HIGH, Constants.CONTENT_VALUE_GRADE_NUM_SECOND)}
            Constants.CONTENT_VALUE_HIGH_third        -> { updateGrade(Constants.CONTENT_VALUE_HIGH, Constants.CONTENT_VALUE_GRADE_NUM_THIRD)}
        }
    }

    private fun updateGrade(grades: String?, grade_num: Int?) {
        grade = grades
        gradeNum = grade_num
    }

    private fun supportManager(bottom_sheet: BottomSheetDialogFragment) {
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottom_sheet.show(supportManager, bottom_sheet.tag)
    }

    private fun initRVLayout() {
        val items = ObservableArrayList<ProgressData>()
        mAdapter = ProgressRVAdapter().apply {
            setHasStableIds(true)
            addItems(items)
        }
        binding.rvSocietyList.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            adapter = mAdapter
            layoutManager = linearLayoutManager
            addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL))
        }
    }

    private fun getSingleJindo(jindo_id: Int) {
        RetrofitClient.getService().getJindoSingle(jindo_id).enqueue( object : Callback<Progress> {
            override fun onFailure(call: Call<Progress>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Progress>, response: Response<Progress>) {
                if (response.isSuccessful) {
                    response.body()?.apply {
                        mAdapter.clear()
                        this.data?.let { mAdapter.addItems(it) }
                    }
                } else Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
            }
        })
    }

    private fun listener(query: HashMap<String, String>) {
        if (grade == Constants.CONTENT_VALUE_ALL_GRADE) grade = null
        RetrofitClient.getService().getJindoList(
            Constants.GRADE_SORT_ID_SOCIETY,
            grade,
            gradeNum,
            query[Constants.REQUEST_KEY_OFFSET]!!,
            Constants.LIMIT_DEFAULT
        ).enqueue(object : Callback<Progress> {
            override fun onFailure(call: Call<Progress>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Progress>, response: Response<Progress>) {
                if (response.isSuccessful) {
                    response.body()?.apply {

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
                } else Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
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
        binding.rvSocietyList.addOnScrollListener(scrollListener)
        scrollListener.resetState()
    }

    private fun loadMoreData(offset: Int) {
        if (isLoading) {
            binding.rvSocietyList.post {
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

}