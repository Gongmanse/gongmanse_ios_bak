@file:Suppress("DEPRECATION")

package com.gongmanse.app.activities

import android.app.ProgressDialog
import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.net.toFile
import androidx.core.widget.doOnTextChanged
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityRegisterUpdateBinding
import com.gongmanse.app.model.User
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import com.google.android.material.textfield.TextInputLayout
import gun0912.tedimagepicker.builder.TedImagePicker
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class RegisterUpdateActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = RegisterUpdateActivity::class.java.simpleName
        private val REGEX_PASSWORD = "^[A-Za-z0-9!@.#$%^&*?_~]*$".toRegex()
        private val REGEX_NICKNAME = "^[A-Za-z0-9가-힣]*$".toRegex()
        private val REGEX_EMAIL = "[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*\\.[a-zA-Z]{2,3}".toRegex()
    }

    private lateinit var binding: ActivityRegisterUpdateBinding
    private lateinit var imm: InputMethodManager
    private var confirmViews = arrayListOf<Int>()
    private var mUserData: User? = null
    private var mUri: Uri? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_register_update)
        initView()
    }

    private fun initView() {
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_REGISTER_UPDATE
        if (intent.hasExtra(Constants.EXTRA_KEY_USER)) {
            mUserData = intent.getSerializableExtra(Constants.EXTRA_KEY_USER) as User
            Log.v(TAG, "mUserData => $mUserData")
            binding.setVariable(BR.data, mUserData)
        }

        imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.showSoftInput(binding.inputPassword, 0)
        imm.showSoftInput(binding.inputPasswordConfirm, 0)
        imm.showSoftInput(binding.inputNickname, 0)
        imm.showSoftInput(binding.inputEmail, 0)

        binding.inputPassword.doOnTextChanged { text, _, _, _ -> checkPassword(text.toString()) }
        binding.inputPasswordConfirm.doOnTextChanged { text, _, _, _ -> checkPasswordConfirm(text.toString()) }
        binding.inputNickname.doOnTextChanged { text, _, _, _ -> checkNickname(text.toString()) }
        binding.inputEmail.doOnTextChanged { text, _, _, _ -> checkEmail(text.toString()) }
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            // 닫기
            R.id.btn_close -> Commons.close(this)
            // 프로필 이미지 변경
            R.id.btn_profile -> setProfilePreview()
            // 적용
            R.id.btn_apply -> upload()
        }
    }

    // 프로필 수정
    private fun setProfilePreview() {
        Log.d(TAG, "onClick => 프로필 이미지 변경")
        TedImagePicker.with(this)
            .start {
                binding.ivProfile.setImageURI(it)

                //이미지 최초 설정 시 visibility 가 GONE 으로 초기화 되어있음.
                binding.ivProfile.visibility = View.VISIBLE
                binding.ivProfileNone.visibility = View.GONE

                mUri = it

                uploadImage()
            }
    }

    private fun checkPassword(str: String) {
        binding.layoutInputPassword.apply {
            when {
                str.isEmpty() -> normal(this)
                ((str.length !in 8..16) or (str.matches(REGEX_PASSWORD).not())) -> error(this, "8~16자의 영문,숫자,특수문자를 사용해주세요.")
                else -> confirm(this)
            }
        }
    }

    private fun checkPasswordConfirm(str: String) {
        val password = binding.inputPassword.text.toString()
        binding.layoutInputPasswordConfirm.apply {
            when {
                str.isEmpty() -> normal(this)
                password != str -> error(this, "비밀번호가 일치하지 않습니다.")
                else -> confirm(this)
            }
        }
    }

    private fun checkNickname(str: String) {
        Log.e(TAG, "nickname => $str | ${mUserData?.sNickname}")
        if (str == mUserData?.sNickname) {
            confirm(binding.layoutInputNickname)
        } else {
            binding.layoutInputNickname.apply {
                when {
                    str.isEmpty() -> normal(this)
                    ((str.length !in 2..12) or (str.matches(REGEX_NICKNAME).not())) -> error(this, "2~12자를 사용하세요.")
                    else -> confirmNicknameDuplication(str)
                }
            }
        }
    }

    private fun checkEmail(str: String) {
        Log.e(TAG, "email => $str | ${mUserData?.sEmail}")
        if (str == mUserData?.sEmail) {
            confirm(binding.layoutInputEmail)
        } else {
            binding.layoutInputEmail.apply {
                when {
                    str.isEmpty() -> normal(this)
                    str.matches(REGEX_EMAIL).not() -> error(this, "이메일 형식에 맞게 입력해주세요.")
                    else -> confirm(this)
                }
            }
        }
    }

    private fun error(layout: TextInputLayout, msg: String) {
        layout.apply {
            error = msg
            endIconMode = TextInputLayout.END_ICON_NONE
            confirmViews.remove(this.id)
        }
        isDoneButton(false)
    }

    private fun confirm(layout: TextInputLayout) {
        layout.apply {
            error = null
            endIconMode = TextInputLayout.END_ICON_CUSTOM
            endIconDrawable = ContextCompat.getDrawable(context, R.drawable.ic_check_correct)
            if (confirmViews.none { it == this.id }) confirmViews.add(this.id)
        }
        isDoneButton(confirmViews.size == 4)
    }

    private fun normal(layout: TextInputLayout) {
        layout.apply {
            error = null
            endIconMode = TextInputLayout.END_ICON_NONE
            confirmViews.remove(this.id)
        }
        isDoneButton(false)
    }

    private fun isDoneButton(isChecked: Boolean) {
        binding.btnApply.apply {
            isClickable = isChecked
            setCardBackgroundColor(if (isChecked) ContextCompat.getColor(context, R.color.main_color) else ContextCompat.getColor(context, R.color.gray))
        }
    }

    private fun upload() {
        GlobalScope.launch(Dispatchers.Main) {
            val asyncDialog = ProgressDialog(this@RegisterUpdateActivity).apply {
                setProgressStyle(ProgressDialog.STYLE_SPINNER)
                setMessage("업로드중입니다...")
                show()
            }
//            val applyImage = mUri?.let { uploadImage(it) }
            val applyProfile = uploadProfile()
            val applyPassword = uploadPassword()
//            Log.d(TAG, "applyImage => $applyImage")
            Log.d(TAG, "applyProfile => $applyProfile")
            Log.d(TAG, "applyPassword => $applyPassword")
            asyncDialog.dismiss()
            if (applyProfile != null /*&& applyImage != null*/ && applyPassword != null) {
                imm.hideSoftInputFromWindow(binding.inputNickname.windowToken, 0)
                imm.hideSoftInputFromWindow(binding.inputPassword.windowToken, 0)
                imm.hideSoftInputFromWindow(binding.inputPasswordConfirm.windowToken, 0)
                imm.hideSoftInputFromWindow(binding.inputEmail.windowToken, 0)
                finish()
            }
        }
    }

    // 프로필 이미지 변경 프로세스 분리
    private fun uploadImage() {
        GlobalScope.launch(Dispatchers.Main) {
            val asyncDialog = ProgressDialog(this@RegisterUpdateActivity).apply {
                setProgressStyle(ProgressDialog.STYLE_SPINNER)
                setMessage("업로드중입니다...")
                show()
            }
            val applyImage = mUri?.let { uploadImage(it) }
            Log.d(TAG, "applyImage => $applyImage")
            asyncDialog.dismiss()
        }
    }

    private fun confirmNicknameDuplication(text: String) {
        RetrofitClient.getService().confirmNicknameDuplication(text).enqueue(object : Callback<Map<String, String>> {
            override fun onFailure(call: Call<Map<String, String>>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, String>>, response: Response<Map<String, String>>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    Log.d(TAG, "response body => ${response.body()}")
                    response.body()?.apply {
                        if (this["data"] == "1") error(binding.layoutInputNickname, "중복된 닉네임입니다.")
                        else confirm(binding.layoutInputNickname)
                    }
                }
            }
        })
    }

    @Suppress("BlockingMethodInNonBlockingContext")
    private suspend fun uploadProfile(): ResponseBody? {
        return  withContext(Dispatchers.IO) {
            val nickname = binding.inputNickname.text.toString()
            val email = binding.inputEmail.text.toString()
            RetrofitClient.getService().uploadProfileInfo(Preferences.token, nickname, email).execute().body()
        }
    }

    @Suppress("BlockingMethodInNonBlockingContext")
    private suspend fun uploadPassword(): ResponseBody? {
        return  withContext(Dispatchers.IO) {
            val password = binding.inputPassword.text.toString()
            RetrofitClient.getService().findRecoverPassword(Preferences.token, password).execute().body()
        }
    }

    @Suppress("BlockingMethodInNonBlockingContext")
    private suspend fun uploadImage(uri: Uri): ResponseBody? {
        return  withContext(Dispatchers.IO) {
            val tokenForm = Preferences.token.toRequestBody("text/plain".toMediaTypeOrNull())
            val reqFile = uri.toFile().asRequestBody("multipart/form-data".toMediaTypeOrNull())
            val body = MultipartBody.Part.createFormData("file", uri.toFile().name, reqFile)
            RetrofitClient.getServiceFile().uploadProfileImage(tokenForm, body).execute().body()
        }
    }

}