package com.gongmanse.app.activities

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivitySettingBinding
import com.gongmanse.app.fragments.sheet.SelectionSheetGrade
import com.gongmanse.app.fragments.sheet.SelectionSheetSubject
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import com.gongmanse.app.listeners.OnBottomSheetSubjectListener
import com.gongmanse.app.model.SettingInfo
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import kotlinx.android.synthetic.main.activity_setting.*
import org.jetbrains.anko.toast
import org.koin.android.ext.android.bind
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.lang.reflect.Type
import kotlin.properties.Delegates

class SettingActivity : AppCompatActivity(), View.OnClickListener, OnBottomSheetProgressListener, OnBottomSheetSubjectListener {

    companion object {
        private val TAG = SettingActivity::class.java.simpleName
    }

    private lateinit var binding: ActivitySettingBinding
    private lateinit var bottomSheetGrade: SelectionSheetGrade
    private lateinit var bottomSheetSubject: SelectionSheetSubject
    private var gray by Delegates.notNull<Int>()
    private var darkGray by Delegates.notNull<Int>()
    private val subjectAllNumber = 38

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_setting)
        initView()
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            // 닫기
            R.id.tv_grade -> {
                val grade = binding.tvGrade.text.toString()
                bottomSheetGrade = SelectionSheetGrade(this, grade)
                selectShow(bottomSheetGrade)
            }
            R.id.tv_subject -> {
                val subject = binding.tvSubject.text.toString()
                bottomSheetSubject = SelectionSheetSubject(this, subject)
                selectShow(bottomSheetSubject)
            }
            R.id.btn_close -> Commons.close(this)
            R.id.sw_sub_title -> {
                Preferences.subtitle = sw_sub_title.isChecked
                if (Preferences.subtitle) {
                    binding.swSubTitle.text = Constants.CONTENT_VALUE_SUBTITLE_ON
                } else {
                    binding.swSubTitle.text = Constants.CONTENT_VALUE_SUBTITLE_OFF
                }
            }
            R.id.sw_data -> {
                Preferences.mobileData = binding.swData.isChecked
            }
            R.id.sw_push -> {
                Preferences.push = binding.swPush.isChecked
                if (Preferences.push) {
                    Preferences.apply {
                        specialist = true
                        inquiry = true
                        schedule = true
                        notice = true
                    }
                    binding.apply {
                        swPushSpecialist.isChecked = true
                        swPushOneOnOneInquiry.isChecked = true
                        swPushMySchedule.isChecked = true
                        swPushNotice.isChecked = true
                        swPushSpecialist.setTextColor(darkGray)
                        swPushOneOnOneInquiry.setTextColor(darkGray)
                        swPushMySchedule.setTextColor(darkGray)
                        swPushNotice.setTextColor(darkGray)
                    }
                } else {
                    Preferences.apply {
                        specialist = false
                        inquiry = false
                        schedule = false
                        notice = false
                    }
                    binding.apply {
                        swPushSpecialist.isChecked = false
                        swPushOneOnOneInquiry.isChecked = false
                        swPushMySchedule.isChecked = false
                        swPushNotice.isChecked = false
                        swPushSpecialist.setTextColor(gray)
                        swPushOneOnOneInquiry.setTextColor(gray)
                        swPushMySchedule.setTextColor(gray)
                        swPushNotice.setTextColor(gray)
                    }
                }
            }
            R.id.sw_push_specialist -> {
                if (!Preferences.push) {
                    Preferences.specialist = false
                    binding.swPushSpecialist.isChecked = false
                } else {
                    if (Preferences.specialist) {
                        binding.swPushSpecialist.setTextColor(gray)
                    } else {
                        binding.swPushSpecialist.setTextColor(darkGray)
                    }
                    Preferences.specialist = binding.swPushSpecialist.isChecked
                }
            }
            R.id.sw_push_one_on_one_inquiry -> {
                if (!Preferences.push) {
                    Preferences.inquiry = false
                    binding.swPushOneOnOneInquiry.isChecked = false
                } else {
                    if (Preferences.inquiry) {
                        binding.swPushOneOnOneInquiry.setTextColor(gray)
                    } else {
                        binding.swPushOneOnOneInquiry.setTextColor(darkGray)
                    }
                    Preferences.inquiry = binding.swPushOneOnOneInquiry.isChecked
                }
            }
            R.id.sw_push_my_schedule -> {
                if (!Preferences.push) {
                    Preferences.schedule = false
                    binding.swPushMySchedule.isChecked = false
                } else {
                    if (Preferences.schedule) {
                        binding.swPushMySchedule.setTextColor(gray)
                    } else {
                        binding.swPushMySchedule.setTextColor(darkGray)
                    }
                    Preferences.schedule = binding.swPushMySchedule.isChecked
                }
            }
            R.id.sw_push_notice -> {
                if (!Preferences.push) {
                    Preferences.notice = false
                    binding.swPushNotice.isChecked = false
                } else {
                    if (Preferences.notice) {
                        binding.swPushNotice.setTextColor(gray)
                    } else {
                        binding.swPushNotice.setTextColor(darkGray)
                    }
                    Preferences.notice = binding.swPushNotice.isChecked
                }
            }
        }
    }

    override fun onSelectionUnit(key: String, id: Int?, jindo_title: String) {}

    override fun onSelectionGrade(
        key: String,
        grades: String?,
        grade_title: String?,
        grade_num: Int?
    ) {
        Log.d(TAG, "${key},${grades},${grade_title},${grade_num}")
        binding.tvGrade.text = grade_title
        bottomSheetGrade.dismiss()
        grade_title?.let { Commons.updatePreferencesGrade(it) }
        updateSetting(grade_title, Preferences.subjectId.toString())
    }


    override fun onSelectionSubject(id: Int?, subject: String?) {
        Log.i(TAG, "Id => $id, Subject => $subject")
        binding.tvSubject.text = subject
        if (subject == Constants.CONTENT_VALUE_ALL_GRADE_SERVER) binding.tvSubject.text = Constants.CONTENT_VALUE_ALL_SUBJECT
        bottomSheetSubject.dismiss()
        id?.let { Commons.updatePreferencesSubjectId(id) }
        subject?.let { Commons.updatePreferencesSubject(it)}
        updateSetting(Preferences.grade, id.toString())
    }

    private fun initView() {
        setColor()
        selectedSetting()
        loginCheck()
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_SETTING
    }

    private fun setColor() {
        gray = ContextCompat.getColor(this@SettingActivity, R.color.gray)
        darkGray = ContextCompat.getColor(this@SettingActivity, R.color.dark_gray2)
    }


    private fun loginCheck() {
        if (Preferences.token.isEmpty()) {
            toast("로그인 후 이용해주세요.")
            finish()
        }
    }

    private fun selectShow(bottom_sheet: BottomSheetDialogFragment) {
        val supportManager = this.supportFragmentManager
        bottom_sheet.show(supportManager, bottom_sheet.tag)
    }


    private fun selectedSetting() {

        if (Preferences.token.isNotEmpty()) loadGradeSubject()
        else {
            binding.tvGrade.text   = Constants.CONTENT_VALUE_ALL_GRADE
            binding.tvSubject.text = Constants.CONTENT_VALUE_ALL_SUBJECT
        }
        if (Preferences.subject.isNotEmpty()) {
            binding.tvSubject.text = Preferences.subject
        }
        if (Preferences.grade.isNotEmpty()) {
            binding.tvGrade.text = Preferences.grade
        }
        if (Preferences.subtitle) {
            binding.swSubTitle.isChecked = Preferences.subtitle
            binding.swSubTitle.text = Constants.CONTENT_VALUE_SUBTITLE_ON
        } else {
            binding.swSubTitle.isChecked = Preferences.subtitle
            binding.swSubTitle.text = Constants.CONTENT_VALUE_SUBTITLE_OFF
        }
        if (Preferences.mobileData) {
            binding.swData.isChecked = true
        }
        if (Preferences.push) {
            binding.swPush.isChecked = true
            if (Preferences.specialist) {
                binding.swPushSpecialist.isChecked = true
                binding.swPushSpecialist.setTextColor(darkGray)
            }
            if (Preferences.notice) {
                binding.swPushNotice.isChecked = true
                binding.swPushNotice.setTextColor(darkGray)
            }
            if (Preferences.schedule) {
                binding.swPushMySchedule.isChecked = true
                binding.swPushMySchedule.setTextColor(darkGray)
            }
            if (Preferences.inquiry) {
                binding.swPushOneOnOneInquiry.isChecked = true
                binding.swPushOneOnOneInquiry.setTextColor(darkGray)
            }
        } else {
            binding.swPush.isChecked = false
            binding.swPushSpecialist.isChecked = false
            binding.swPushMySchedule.isChecked = false
            binding.swPushNotice.isChecked = false
            binding.swPushOneOnOneInquiry.isChecked = false
        }
    }

    private fun loadGradeSubject() {
        Log.d(TAG, "loadGradeSubject()")
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
                            Log.i(TAG, "SettingInfo => $list")

                            // 학년
                            Commons.updatePreferencesGrade(list.grade)

                            // 과목
                            Commons.updatePreferencesSubject(list.subject)

                            // 과목 번호 ( 전체: 38 )
                            Preferences.subjectId  = when(list.subjectId) {
                                Constants.CONTENT_VALUE_ALL_SUBJECT -> { subjectAllNumber }
                                "38" -> { subjectAllNumber}
                                null -> { subjectAllNumber}
                                else -> { list.subjectId.toInt()}
                            }
                            Log.i(TAG, "Subject -> id:${Preferences.subjectId}, title:${Preferences.subject}, grade:${Preferences.grade}")
                            binding.setVariable(BR.setting, list)

                        }
                    }
                }
            })
    }

    private fun updateSetting(grade:String?, subject: String?) {
        Log.d(TAG, "updateMyGrade() => grade:$grade, subject:$subject")
        RetrofitClient.getService().updateSettingInfo(Preferences.token, grade, subject).enqueue( object : Callback<Void> {
            override fun onFailure(call: Call<Void>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Void>, response: Response<Void>) {
                Log.i(TAG, "onResponseBody => ${response.body()}")
                if (response.isSuccessful) {
                    response.body()?.let {  }
                }
            }
        })

    }

}