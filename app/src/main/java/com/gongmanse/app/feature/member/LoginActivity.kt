package com.gongmanse.app.feature.member

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.R
import com.gongmanse.app.data.network.member.MemberRepository
import kotlinx.android.synthetic.main.activity_login.*
import org.jetbrains.anko.toast

class LoginActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = LoginActivity::class.java.simpleName
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.iv_close -> finish()
            R.id.btn_login -> login()
            R.id.btn_sign_up -> signUp()
            R.id.btn_find_by_username -> findByUsername()
            R.id.btn_find_by_password -> findByPassword()
        }
    }

    // 로그인
    private fun login() {
        Log.v(TAG, "onClick => 로그인")
        val mMemberViewModelFactory = MemberViewModelFactory(MemberRepository())
        val mMemberViewModel = ViewModelProvider(this, mMemberViewModelFactory).get(MemberViewModel::class.java)
        val username = et_username.text.toString()
        val password = et_password.text.toString()
        mMemberViewModel.login(username, password)
        mMemberViewModel.result.observe(this) {
            if (it != null) {
                Log.d(TAG, "result code => $it")
                when (it) {
                    in 200..299 -> {
                        setResult(RESULT_OK)
                        finish()
                    }
                    in 400..499 -> {
                        toast("아이디 또는 비밀번호를 재확인해주세요.")
                    }
                }
            }
        }
    }

    // 회원가입
    private fun signUp() {
        // TODO 회원가입 화면으로 이동 또는 액티비티 생성
    }

    // 아이디 찾기
    private fun findByUsername() {
        // TODO 아이디 찾기 화면으로 이동 또는 액티비티 생성
    }

    // 비밀번호 찾기
    private fun findByPassword() {
        // TODO 비밀번호 찾기 화면으로 이동 또는 액티비티 생성
    }

}