package com.gongmanse.app.fragments

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.activities.*
import com.gongmanse.app.activities.customer.CustomerServiceActivity
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentDrawerBinding
import com.gongmanse.app.model.User
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.*
import org.jetbrains.anko.support.v4.alert
import org.jetbrains.anko.support.v4.intentFor
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


@Suppress("CAST_NEVER_SUCCEEDS")
class DrawerFragment: Fragment() {

    companion object {
        private val TAG = DrawerFragment::class.java.simpleName
        private const val REQUEST_LOGIN_CODE = 100
        private const val REQUEST_REGISTER_CODE = 200
        private const val REQUEST_REGISTER_UPDATE_CODE = 300
        private const val REQUEST_PASS_CODE = 400

        fun newInstance() = DrawerFragment().apply {
            arguments = androidx.core.os.bundleOf()
        }
    }

    private lateinit var binding: FragmentDrawerBinding

    // 화면 생성
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_drawer, container, false)
        return binding.root
    }

    override fun onResume() {
        super.onResume()
        initView()
    }

    // 액티비티 생성
    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    // 화면 초기화
    private fun initView() {
        if (Preferences.token.isNotEmpty()) getProfile()
        // 클릭 리스너 연결
        binding.apply {
            initDrawerMenu()
            btnClose.setOnClickListener(close)
            btnTermsOfService.setOnClickListener(openTermsOfServiceView)
            btnPrivacy.setOnClickListener(openPrivacyView)
            layoutProfile.apply {
                btnLogin.setOnClickListener(login)
                btnLogout.setOnClickListener(logout)
                btnSignUp.setOnClickListener(openRegisterView)
                btnModProfile.setOnClickListener(openProfileView)
                btnPurchasePass.setOnClickListener(openPassView)
            }
        }
    }

    // 리턴 이벤트
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode != Activity.RESULT_OK) {
            return
        }
        // 로그인
        if (requestCode == REQUEST_LOGIN_CODE) {
            Log.v(TAG, "requestCode => REQUEST_LOGIN_CODE... => ${Preferences.token}")
            getProfile()
        }
        // 회원가입
        if (requestCode == REQUEST_REGISTER_CODE) {
            Log.v(TAG, "requestCode => REQUEST_REGISTER_CODE... => ${Preferences.token}")
            getProfile()
        }
        // 프로필 수정
        if (requestCode == REQUEST_REGISTER_UPDATE_CODE) {
            Log.v(TAG, "requestCode => REQUEST_REGISTER_UPDATE_CODE...")
            getProfile()
        }

    }

    // 프로필 정보 로드
    private fun getProfile() {
        Log.v(TAG, "getProfile... => ${Preferences.token}")
        RetrofitClient.getService().getUserInfo(Preferences.token).enqueue(object : Callback<User> {
            override fun onFailure(call: Call<User>, t: Throwable) {
                Log.v(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<User>, response: Response<User>) {
                if (!response.isSuccessful) Log.v(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.v(TAG, "onResponse => $this")
                        binding.setVariable(BR.data, this)
                        Preferences.expire = this.dtPremiumExpire ?: ""
                    }
                }
            }
        })
    }

    // 닫기
    private val close = View.OnClickListener {
        Log.v(TAG, "onClick => 닫기")
        (context as MainActivity).closeDrawer()
    }

    // 로그인
    private val login = View.OnClickListener {
        Log.v(TAG, "onClick => 로그인")
        startActivityForResult(intentFor<LoginActivity>(), REQUEST_LOGIN_CODE)
    }

    // 로그아웃
    private val logout = View.OnClickListener {
        Log.v(TAG, "onClick => 로그아웃")
        alert(message = resources.getString(R.string.content_text_would_you_like_to_logout)) {
            noButton { dialog -> dialog.dismiss() }
            yesButton {
                Preferences.token = ""
                Preferences.refresh = ""
                Commons.apply {
                    updatePreferencesGrade(null)
                    updatePreferencesSubject(null)
                    updatePreferencesSubjectId(0)
                }
                (context as MainActivity).updateGradeAndSubject()
                binding.setVariable(BR.data, null)

            }
        }.show()
    }

    // 메뉴 초기화
    private fun initDrawerMenu() {
        // 나의 활동
        binding.btnMyActive.setOnClickListener {
            binding.root.context.apply {
                hasLogin(this, intentFor<MyActiveActivity>().singleTop())
            }
        }
        // 나의 일정
        binding.btnMySchedule.setOnClickListener {
            binding.root.context.apply {
                hasLogin(this,intentFor<MyScheduleActivity>().singleTop())
            }
        }
        // 공만세란?
        binding.btnWhatSGongmanse.setOnClickListener {
            binding.root.context.apply {
                startActivity(intentFor<WhatIsGongmanseActivity>().singleTop())
            }
        }
        // 공지사항
        binding.btnNotice.setOnClickListener {
            binding.root.context.apply {
                hasLogin(this, intentFor<NoticeActivity>().singleTop())
            }
        }
        // 고객센터
        binding.btnHelpCenter.setOnClickListener {
            binding.root.context.apply {
                startActivity(intentFor<CustomerServiceActivity>().singleTop())
            }
        }
        // 설정
        binding.btnSettings.setOnClickListener {
            binding.root.context.apply {
                hasLogin(this,intentFor<SettingActivity>().singleTop())
            }
        }
    }

    // 회원가입
    private val openRegisterView = View.OnClickListener {
        Log.v(TAG, "onClick => 회원가입")
        startActivityForResult(intentFor<RegisterActivity>(), REQUEST_REGISTER_CODE)
    }

    // 프로필 수정
    private val openProfileView = View.OnClickListener {
        Log.v(TAG, "onClick => 프로필 수정")
        startActivityForResult(intentFor<RegisterUpdateActivity>(Constants.EXTRA_KEY_USER to binding.data), REQUEST_REGISTER_UPDATE_CODE)
    }

    // 이용권 구매
    private val openPassView = View.OnClickListener {
        Log.v(TAG, "onClick => 이용권 구매")
        startActivityForResult(intentFor<PassActivity>(), REQUEST_PASS_CODE)
    }

    // 이용약관
    private val openTermsOfServiceView = View.OnClickListener {
        Log.v(TAG, "onClick => 이용약관")
        startActivity(intentFor<TermsOfServiceActivity>().singleTop())
    }

    // 개인정보처리방침
    private val openPrivacyView = View.OnClickListener {
        Log.v(TAG, "onClick => 개인정보처리방침")
        startActivity(intentFor<PrivacyPolicyActivity>().singleTop())
    }

    private fun hasLogin(context: Context, intent: Intent) {
        context.apply {
            if (Preferences.token.isEmpty()) {
                alert(message = resources.getString(R.string.content_text_would_you_like_to_login)) {
                    yesButton { startActivity(intentFor<LoginActivity>().singleTop()) }
                    noButton { dialog -> dialog.dismiss() }
                }.show()
            } else {
                startActivity(intent)
            }
        }
    }

}