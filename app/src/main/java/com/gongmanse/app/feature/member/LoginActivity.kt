package com.gongmanse.app.feature.member

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.R
import com.gongmanse.app.data.network.member.MemberRepository
import com.gongmanse.app.databinding.LayoutLocalHeaderBinding
import com.gongmanse.app.databinding.LayoutLoginHeaderBinding
import kotlinx.android.synthetic.main.activity_login.*
import kotlinx.android.synthetic.main.activity_main.*
import okhttp3.OkHttp
import okhttp3.OkHttpClient
import okhttp3.Response
import okhttp3.ResponseBody
import okhttp3.internal.http.HttpMethod
import org.jetbrains.anko.toast
import retrofit2.Retrofit
import retrofit2.http.HTTP
import java.net.HttpURLConnection
import javax.net.ssl.HttpsURLConnection

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
                    HttpURLConnection.HTTP_OK -> {
                        setResult(RESULT_OK)
                        finish()
                    }
                    HttpURLConnection.HTTP_BAD_REQUEST -> {
                        toast("아이디 또는 비밀번호를 재확인해주세요.")
                    }
                }
            }
        }
    }

    // 회원가입
    private fun signUp() {
        Log.v(TAG, "onClick => 회원가입")
    }

    // 아이디 찾기
    private fun findByUsername() {
        Log.v(TAG, "onClick => 아이디 찾기")
    }

    // 비밀번호 찾기
    private fun findByPassword() {
        Log.v(TAG, "onClick => 비밀번호 찾기")
    }

}