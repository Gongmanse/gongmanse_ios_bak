package com.gongmanse.app.activities

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import com.google.android.material.textfield.TextInputLayout
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityEnterNewPasswordBinding
import com.gongmanse.app.utils.Constants
import okhttp3.ResponseBody
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class EnterNewPasswordActivity : AppCompatActivity() {

    companion object {
        private val TAG = EnterNewPasswordActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityEnterNewPasswordBinding
    private var userName: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_enter_new_password)
        initView()
    }

    private fun initView() {
        if (intent.hasExtra(Constants.EXTRA_KEY_USER_NAME)) {
            userName = intent.getStringExtra(Constants.EXTRA_KEY_USER_NAME)
            Log.d(TAG, "userName => $userName")
        }

        binding.inputPassword.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {}
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                checkPassword(s.toString())
            }
        })
        binding.inputPasswordConfirm.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {}
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                checkPasswordConfirm(s.toString())
            }
        })
    }

    private fun checkPassword(str: String) {
        if (str.isEmpty()) {
            binding.layoutInputPassword.error = null
            binding.layoutInputPassword.endIconMode = TextInputLayout.END_ICON_NONE
            return
        }
        if ((str.length < 8) or (str.length > 16)) {
            binding.layoutInputPassword.error = "8~16자, 영문 대소문자, 숫자, 특수문자를 사용해주세요."
            binding.layoutInputPassword.endIconMode = TextInputLayout.END_ICON_NONE
            checkDoneView()
            return
        }
        val password = binding.inputPasswordConfirm.text.toString()
        if ((str.isNotEmpty() and password.isNotEmpty()) and (str != password)) {
            binding.layoutInputPasswordConfirm.error = "비밀번호가 일치하지 않습니다."
            binding.layoutInputPasswordConfirm.endIconMode = TextInputLayout.END_ICON_NONE
        }
        binding.layoutInputPassword.apply {
            error = null
            endIconMode = TextInputLayout.END_ICON_CUSTOM
            endIconDrawable = ContextCompat.getDrawable(this@EnterNewPasswordActivity, R.drawable.ic_check_correct)
            checkDoneView()
        }
    }

    private fun checkPasswordConfirm(str: String) {
        val password = binding.inputPassword.text.toString()
        if (str.isEmpty()) {
            binding.layoutInputPasswordConfirm.error = null
            binding.layoutInputPasswordConfirm.endIconMode = TextInputLayout.END_ICON_NONE
            return
        }
        if ((password.isNotEmpty()) and (password != str)) {
            binding.layoutInputPasswordConfirm.error = "비밀번호가 일치하지 않습니다."
            binding.layoutInputPasswordConfirm.endIconMode = TextInputLayout.END_ICON_NONE
            checkDoneView()
            return
        }
        binding.layoutInputPasswordConfirm.apply {
            error = null
            endIconMode = TextInputLayout.END_ICON_CUSTOM
            endIconDrawable = ContextCompat.getDrawable(this@EnterNewPasswordActivity, R.drawable.ic_check_correct)
            checkDoneView()
        }
    }

    private fun checkDoneView() {
        when {
            binding.inputPassword.text.toString().isEmpty() or binding.inputPasswordConfirm.text.toString().isEmpty() -> {
                binding.layoutButtonDone.btnDone.apply {
                    isClickable = false
                    setCardBackgroundColor(ContextCompat.getColorStateList(this@EnterNewPasswordActivity, R.color.gray))
                    setOnClickListener(null)
                }
            }
            (binding.layoutInputPassword.error != null) or (binding.layoutInputPasswordConfirm.error != null) -> {
                binding.layoutButtonDone.btnDone.apply {
                    isClickable = false
                    setCardBackgroundColor(ContextCompat.getColorStateList(this@EnterNewPasswordActivity, R.color.gray))
                    setOnClickListener(null)
                }
            }
            else -> {
                binding.layoutButtonDone.btnDone.apply {
                    isClickable = true
                    setCardBackgroundColor(ContextCompat.getColorStateList(this@EnterNewPasswordActivity, R.color.main_color))
                    setOnClickListener {
                        if (userName == null) {
                            toast("아이디 정보가 없습니다.")
                            finish()
                            return@setOnClickListener
                        }
                        RetrofitClient.getService().findRecoverPassword1(userName!!, binding.inputPasswordConfirm.text.toString()).enqueue(object : Callback<ResponseBody> {
                            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                            }

                            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                                if (response.isSuccessful) {
                                    response.body()?.apply {
                                        Log.d(TAG, "onResponse => $this")
                                        startActivity(intentFor<ResultFindPasswordActivity>().singleTop())
                                        finish()
                                    }
                                } else Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                            }
                        })
                    }
                }
            }
        }
    }

}