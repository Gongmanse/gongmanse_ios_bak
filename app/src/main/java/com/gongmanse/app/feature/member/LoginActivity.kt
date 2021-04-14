package com.gongmanse.app.feature.member

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.gongmanse.app.R

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
            R.id.btn_find_by_username -> findId()
            R.id.btn_find_by_password -> findPassword()
            R.id.btn_sign_up -> signUp()
        }
    }

    // 로그인
    private fun login() {
        Log.v(TAG, "onClick => 로그인")
    }

    // 아이디 찾기
    private fun findId() {
        Log.v(TAG, "onClick => 아이디 찾기")
    }

    // 비밀번호 찾기
    private fun findPassword() {
        Log.v(TAG, "onClick => 비밀번호 찾기")
    }

    // 회원가입
    private fun signUp() {
        Log.v(TAG, "onClick => 회원가입")
    }

}