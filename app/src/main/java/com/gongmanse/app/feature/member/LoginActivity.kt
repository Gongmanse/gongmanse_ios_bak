package com.gongmanse.app.feature.member

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.R
import com.gongmanse.app.data.network.member.MemberRepository
import com.gongmanse.app.databinding.ActivityLoginBinding
import kotlinx.android.synthetic.main.activity_login.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.jetbrains.anko.toast

class LoginActivity : AppCompatActivity(), View.OnClickListener {

    private lateinit var binding: ActivityLoginBinding
    private lateinit var mMemberViewModel: MemberViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        bindUI()
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.iv_close -> finish()
        }
    }

    private fun bindUI() {
        binding = ActivityLoginBinding.inflate(layoutInflater).apply {
            this@LoginActivity.let { context ->
                val mMemberViewModelFactory = MemberViewModelFactory(MemberRepository())
                mMemberViewModel = ViewModelProvider(context, mMemberViewModelFactory).get(MemberViewModel::class.java)
                viewModel = mMemberViewModel
                lifecycleOwner = context
            }
        }
        setContentView(binding.root)
        CoroutineScope(Dispatchers.Main).launch {
            setupLogin()
        }
    }

    // 로그인
    private fun setupLogin() {
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

    companion object {
        private val TAG = LoginActivity::class.java.simpleName
    }

}