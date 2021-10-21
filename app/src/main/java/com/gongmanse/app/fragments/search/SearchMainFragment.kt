package com.gongmanse.app.fragments.search

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import com.gongmanse.app.R
import com.gongmanse.app.activities.SearchResultActivity
import com.gongmanse.app.adapter.search.SearchTabPagerAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentSearchMainBinding
import com.gongmanse.app.fragments.sheet.SelectionSheetSearchGrade
import com.gongmanse.app.fragments.sheet.SelectionSheetSubject
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import com.gongmanse.app.listeners.OnBottomSheetSubjectListener
import com.gongmanse.app.listeners.OnSearchKeywordListener
import com.gongmanse.app.model.SettingInfo
import com.gongmanse.app.utils.*
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.material.tabs.TabLayout
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.support.v4.intentFor
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.lang.reflect.Type


class SearchMainFragment : Fragment(), OnBottomSheetProgressListener, OnBottomSheetSubjectListener,
    OnSearchKeywordListener {

    companion object {
        private val TAG = SearchMainFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentSearchMainBinding
    private lateinit var bottomSheetSearchGrade: SelectionSheetSearchGrade
    private lateinit var bottomSheetSubject: SelectionSheetSubject
    private lateinit var mAdapter: SearchTabPagerAdapter
    private lateinit var searchHotFragment: SearchHotFragment
    private lateinit var searchRecentFragment: SearchRecentFragment

    private var currentFragment: Fragment? = null
    private var grade: String? = null
    private var keyword: String? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_search_main, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onStart() {
        super.onStart()
        initView()
    }

    override fun onResume() {
        super.onResume()
        initView()
    }

    // 인기, 최근 검색어: 클릭 -> 검색바에 셋팅
    override fun onSearchKeyword(clickKeyword: String?) {
        if (clickKeyword != null) {
            binding.inputSearch.setText(clickKeyword)
            keyword = clickKeyword
            searchKeyword()
            Log.d(TAG, "hotKeyword => $clickKeyword")
        } else keyword = null
    }

    /**
     * 선택:
     * @param grades      = 초, 중, 고등
     * @param grade_title = 초등학교 1학년, setText 용도
     * @param grade_num   = 초등학교 '1'학년, iGrade  용도
     * */
    override fun onSelectionGrade(
        key: String,
        grades: String?,
        grade_title: String?,
        grade_num: Int?
    ) {
        Log.i(TAG, "key:$key, grade:$grades, grade_title:$grade_title grade_num:$grade_num")
        binding.tvGrade.text = grade_title
        bottomSheetSearchGrade.dismiss()
        grade_title?.let { grade = it }
    }

    /**
     * 선택:
     * @param id        = 과목 고유 번호
     * @param subject   = 과목
     * */
    override fun onSelectionSubject(id: Int?, subject: String?) {
        Log.i(TAG, "Id => $id, Subject => $subject")
        binding.tvSubject.text = subject
        bottomSheetSubject.dismiss()
        id?.let { Commons.updatePreferencesSubjectId(id) }
        subject?.let { Commons.updatePreferencesSubject(it) }
    }

    override fun onSelectionUnit(key: String, id: Int?, jindo_title: String) {}

    private fun initView() {

        searchHotFragment = SearchHotFragment.newInstance(this)
        searchRecentFragment = SearchRecentFragment.newInstance(this)

        mAdapter = SearchTabPagerAdapter(childFragmentManager)
        binding.tabLayout.addOnTabSelectedListener(onTabSelectedListener)
        binding.viewPager.apply {
            adapter = mAdapter
            offscreenPageLimit = 2
            binding.tabLayout.setupWithViewPager(this)
        }
        selectedSetting()
        setClickEvent()
    }

    private val onTabSelectedListener = object : TabLayout.OnTabSelectedListener {
        override fun onTabUnselected(tab: TabLayout.Tab?) {}

        override fun onTabReselected(tab: TabLayout.Tab?) {
            when(currentFragment) {
                is SearchHotFragment -> {
                    (currentFragment as SearchHotFragment).scrollToTop()
                }
                is SearchRecentFragment -> {
                    (currentFragment as SearchRecentFragment).scrollToTop()
                }
            }
        }

        override fun onTabSelected(tab: TabLayout.Tab?) {
            tab?.position?.let {
                currentFragment = mAdapter.getItem(it)
            }
        }
    }

    // 클릭 이벤트
    private fun setClickEvent() {
        binding.apply {
            /* Select Box */
            // 학년
            layoutGrade.setOnClickListener {
                bottomSheetSearchGrade = SelectionSheetSearchGrade(
                    this@SearchMainFragment,
                    tvGrade.text.toString()
                )
                selectShow(bottomSheetSearchGrade)
            }
            // 과목
            layoutSubject.setOnClickListener {
                bottomSheetSubject = SelectionSheetSubject(
                    this@SearchMainFragment,
                    tvSubject.text.toString()
                )
                selectShow(bottomSheetSubject)
            }
            // 키보드 패드, 검색 아이콘
            inputSearch.setOnEditorActionListener(fun(_, actionId: Int, _): Boolean {
                when (actionId) {
                    EditorInfo.IME_ACTION_SEARCH -> {
                        searchKeyword()
                        return false
                    }
                }
                return true
            })
            btnSearch.setOnClickListener { searchKeyword() }
        }
    }

    // 검색: 결과 화면으로 이동
    private fun searchKeyword() {
        keyword = binding.inputSearch.text.toString()
        if (Preferences.token.isNotEmpty()) updateRecentSearchKeyword(Preferences.token, keyword)
            startActivity(
                intentFor<SearchResultActivity>(
                    Constants.EXTRA_KEY_GRADE to grade,
                    Constants.EXTRA_KEY_SUBJECT_ID to Preferences.subjectId,
                    Constants.EXTRA_KEY_KEYWORD to keyword
                ).singleTop()
            )
    }

    // 계정: 최근 검색어 Update
    private fun updateRecentSearchKeyword(token: String, keyword: String?) {
        RetrofitClient.getService().updateRecentKeyword(token, keyword)
            .enqueue(object : Callback<Map<String, Any>> {
                override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                    Log.e(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(
                    call: Call<Map<String, Any>>,
                    response: Response<Map<String, Any>>
                ) {
                    if (response.isSuccessful) {
                        response.body()?.apply {
                            Log.i(TAG, "update onResponse Body => ${response.body()}") }
                    } else {
                        Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                    }
                }
            })

    }

    private fun selectShow(bottom_sheet: BottomSheetDialogFragment) {
        val supportManager = (context as FragmentActivity).supportFragmentManager
        bottom_sheet.show(supportManager, bottom_sheet.tag)
    }

    // 설정: 과목 및 학년
    private fun selectedSetting() {
        Log.d(TAG, "selectedSetting => grade:${Preferences.grade}, \n subject => ${Preferences.subject}")

        binding.apply {
            if (Preferences.grade.isNotEmpty()) {
                Log.d(TAG, "Preferences.grade is NotEmpty => ${Preferences.grade}")
                checkGrade(Preferences.grade)
            }
            else {
                grade = Constants.CONTENT_VALUE_ALL_GRADE
                tvGrade.text = Constants.CONTENT_VALUE_ALL_GRADE
                Log.d(TAG, "Preferences.grade is Empty => ${Preferences.grade}")
            }
            if (Preferences.subject.isEmpty()) {
                Log.d(TAG,"Preference.subject is Empty")
                tvSubject.text = Constants.CONTENT_VALUE_ALL_SUBJECT
            }
            else {
                if (Preferences.token.isEmpty()) {
                    tvSubject.text = Commons.updatePreferencesSubject(null)
                    Commons.updatePreferencesSubjectId(38)
                }
                else {
                    loadSettings()
                    GradeAndSubjectCheck.checkSubjectList(Preferences.subject)
                }
                Log.d(TAG, "Result checkSubjectList:${Preferences.subjectId}")
            }
        }
    }

    private fun checkGrade(value: String) {
            if (value.isEmpty()) {
                Log.d(TAG, "checkGrade value is null => $value")
                grade = Constants.CONTENT_VALUE_ALL_GRADE
                binding.tvGrade.text = Constants.CONTENT_VALUE_ALL_GRADE
            } else {
                grade = when(value[0]) {
                    '초' -> Constants.CONTENT_VALUE_ELEMENTARY
                    '중' -> Constants.CONTENT_VALUE_MIDDLE
                    '고' -> Constants.CONTENT_VALUE_HIGH
                    else -> null
                }
                binding.tvGrade.text = if (grade.isNullOrEmpty()) Constants.CONTENT_VALUE_ALL_GRADE else grade
            }
    }

    fun updateGradeAndSubject() {
        Log.d(TAG, "updateGradeAndSubject()")
        initView()
    }

    private fun loadSettings() {
        Log.v(TAG, "onClick => loadSettings")
        RetrofitClient.getService().getSettingInfo(Preferences.token).enqueue(object : Callback<Map<String, Any>> {
            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, Any>>, response: Response<Map<String, Any>>) {
                Log.i(TAG, "onResponseBody => ${response.body()}")
                if (response.isSuccessful) {
                    response.body()?.let {
                        val type: Type = object : TypeToken<SettingInfo>() {}.type
                        val jsonResult = Gson().toJson(it["data"])
                        val list = Gson().fromJson<SettingInfo>(jsonResult, type)

                        // 학년
                        Commons.updatePreferencesGrade(list.grade)

                        // 과목
                        Commons.updatePreferencesSubject(list.subject)

                        // 과목 번호 ( 전체: 38 )
                        val subjectAllNumber = 38
                        Preferences.subjectId  = when(list.subjectId) {
                            Constants.CONTENT_VALUE_ALL_SUBJECT -> { subjectAllNumber }
                            "38" -> { subjectAllNumber }
                            null -> { subjectAllNumber }
                            else -> { list.subjectId.toInt() }
                        }

                        binding.apply {
                            tvSubject.text = when(tvSubject.text) {
                                null -> Constants.CONTENT_VALUE_ALL_SUBJECT
                                "null" -> Constants.CONTENT_VALUE_ALL_SUBJECT
                                else   -> Preferences.subject
                            }
                        }

                    }
                }
            }
        })
    }

}