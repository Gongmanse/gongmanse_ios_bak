package com.gongmanse.app.fragments.register

import android.content.Context
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import androidx.core.content.ContextCompat
import androidx.core.widget.doOnTextChanged
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.google.android.material.textfield.TextInputLayout
import com.gongmanse.app.R
import com.gongmanse.app.activities.RegisterActivity
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentRegisterFormBinding
import com.gongmanse.app.utils.Constants
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class RegisterFormFragment: Fragment() {

    companion object {
        private val TAG = RegisterFormFragment::class.java.simpleName
        /* Regex */
        private val REGEX_ID = "^[_A-Za-z0-9-]*$".toRegex()
        private val REGEX_PASSWORD = "^[A-Za-z0-9!@.#$%^&*?_~]*$".toRegex()
        private val REGEX_NICKNAME = "^[A-Za-z0-9가-힣]*$".toRegex()
        private val REGEX_NAME = "^[가-힣]*$".toRegex()
        private val REGEX_EMAIL = "[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*\\.[a-zA-Z]{2,3}".toRegex()
    }

    private lateinit var binding: FragmentRegisterFormBinding
    private lateinit var imm: InputMethodManager
    private var confirmViews = arrayListOf<Int>()
    private var mRegister = hashMapOf<String, String>()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_register_form, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        imm = context?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.showSoftInput(binding.inputId, 0)
        imm.showSoftInput(binding.inputNickname, 0)
        imm.showSoftInput(binding.inputPassword, 0)
        imm.showSoftInput(binding.inputPasswordConfirm, 0)
        imm.showSoftInput(binding.inputName, 0)
        imm.showSoftInput(binding.inputEmail, 0)
        isActiveButton()
        binding.inputId.doOnTextChanged { text, _, _, _ -> checkId(text.toString()) }
        binding.inputNickname.doOnTextChanged { text, _, _, _ -> checkNickname(text.toString()) }
        binding.inputPassword.doOnTextChanged { text, _, _, _ -> checkPassword(text.toString()) }
        binding.inputPasswordConfirm.doOnTextChanged { text, _, _, _ -> checkPasswordConfirm(text.toString()) }
        binding.inputName.doOnTextChanged { text, _, _, _ -> checkName(text.toString()) }
        binding.inputEmail.doOnTextChanged { text, _, _, _ -> checkEmail(text.toString()) }
    }

    private val nextView = View.OnClickListener {
        Log.d(TAG, "click => next")
        (activity as RegisterActivity).apply {
            imm.hideSoftInputFromWindow(binding.inputId.windowToken, 0)
            imm.hideSoftInputFromWindow(binding.inputNickname.windowToken, 0)
            imm.hideSoftInputFromWindow(binding.inputPassword.windowToken, 0)
            imm.hideSoftInputFromWindow(binding.inputPasswordConfirm.windowToken, 0)
            imm.hideSoftInputFromWindow(binding.inputName.windowToken, 0)
            imm.hideSoftInputFromWindow(binding.inputEmail.windowToken, 0)
            nextVerification(mRegister)
        }
    }

    private fun isActiveButton() {
        Log.d(TAG, "confirmViews => $confirmViews")
        if (confirmViews.size == 6) {
            binding.layoutButtonNext.btnNext.apply {
                isClickable = true
                setCardBackgroundColor(ContextCompat.getColor(context, R.color.main_color))
                setOnClickListener(nextView)
            }
        } else {
            binding.layoutButtonNext.btnNext.apply {
                isClickable = false
                setCardBackgroundColor(ContextCompat.getColor(context, R.color.gray))
                setOnClickListener(null)
            }
        }
    }

    private fun confirmIdDuplication(text: String) {
        RetrofitClient.getService().confirmIdDuplication(text).enqueue(object : Callback<Map<String, String>> {
            override fun onFailure(call: Call<Map<String, String>>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, String>>, response: Response<Map<String, String>>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    Log.d(TAG, "response body => ${response.body()}")
                    response.body()?.apply {
                        if (this[Constants.RESPONSE_KEY_DATA] == Constants.RESPONSE_KEY_DATA_OK) error(binding.layoutInputId, getString(R.string.content_text_duplicate_id))
                        else confirm(binding.layoutInputId)
                    }
                }
            }
        })
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
                        if (this["data"] == "1") error(binding.layoutInputNickname, getString(R.string.content_text_duplicate_nickname))
                        else confirm(binding.layoutInputNickname)
                    }
                }
            }
        })
    }

    private fun checkId
                (str: String) {
        binding.layoutInputId.apply {
            mRegister[Constants.REQUEST_KEY_USERNAME] = binding.inputId.text.toString()
            when {
                str.isEmpty() -> normal(this)
                ((str.length < 2 ) or (str.matches(REGEX_ID).not())) -> error(this, getString(R.string.content_text_please_id_regex))
                else -> confirmIdDuplication(str)
            }
        }
    }

    private fun checkNickname(str: String) {
        binding.layoutInputNickname.apply {
            mRegister[Constants.REQUEST_KEY_NICKNAME] = binding.inputNickname.text.toString()
            when {
                str.isEmpty() -> normal(this)
                ((str.length !in 2..12) or (str.matches(REGEX_NICKNAME).not())) -> error(this, getString(R.string.content_text_please_nickname_regex))
                else -> confirmNicknameDuplication(str)
            }
        }
    }

    private fun checkPassword(str: String) {
        binding.layoutInputPassword.apply {
            mRegister[Constants.REQUEST_KEY_PASSWORD] = binding.inputPassword.text.toString()
            when {
                str.isEmpty() -> normal(this)
                ((str.length !in 8..16) or (str.matches(REGEX_PASSWORD).not())) -> error(this, getString(R.string.content_text_please_password_regex))
                else -> confirm(this)
            }
        }
    }

    private fun checkPasswordConfirm(str: String) {
        val password = binding.inputPassword.text.toString()
        binding.layoutInputPasswordConfirm.apply {
            mRegister[Constants.REQUEST_KEY_PASSWORD_CONFIRM] = binding.inputPasswordConfirm.text.toString()
            when {
                str.isEmpty() -> normal(this)
                password != str -> error(this, getString(R.string.content_text_password_does_not_match))
                else -> confirm(this)
            }
        }
    }

    private fun checkName(str: String) {
        binding.layoutInputName.apply {
            mRegister[Constants.REQUEST_KEY_NAME] = binding.inputName.text.toString()
            when {
                str.isEmpty() -> normal(this)
                str.matches(REGEX_NAME).not() -> error(this, getString(R.string.content_text_please_name_regex))
                else -> confirm(this)
            }
        }
    }

    private fun checkEmail(str: String) {
        binding.layoutInputEmail.apply {
            mRegister[Constants.REQUEST_KEY_EMAIL] = binding.inputEmail.text.toString()
            when {
                str.isEmpty() -> normal(this)
                str.matches(REGEX_EMAIL).not() -> error(this, getString(R.string.content_text_please_email_regex))
                else -> confirm(this)
            }
        }
    }

    private fun error(layout: TextInputLayout, msg: String) {
        layout.apply {
            error = msg
            endIconMode = TextInputLayout.END_ICON_NONE
            confirmViews.remove(this.id)
        }
        isActiveButton()
    }

    private fun confirm(layout: TextInputLayout) {
        layout.apply {
            error = null
            endIconMode = TextInputLayout.END_ICON_CUSTOM
            endIconDrawable = ContextCompat.getDrawable(context, R.drawable.ic_check_correct)
            if (confirmViews.none { it == this.id }) confirmViews.add(this.id)
        }
        isActiveButton()
    }

    private fun normal(layout: TextInputLayout) {
        layout.apply {
            error = null
            endIconMode = TextInputLayout.END_ICON_NONE
            confirmViews.remove(this.id)
        }
        isActiveButton()
    }

}

