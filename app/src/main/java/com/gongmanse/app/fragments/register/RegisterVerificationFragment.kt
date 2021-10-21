package com.gongmanse.app.fragments.register

import android.content.Context
import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import androidx.core.content.ContextCompat
import androidx.core.widget.doAfterTextChanged
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.activities.RegisterActivity
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentRegisterVerificationBinding
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.support.v4.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*
import kotlin.collections.HashMap


@Suppress("DEPRECATION")
class RegisterVerificationFragment: Fragment() {

    companion object {
        private val TAG = RegisterVerificationFragment::class.java.simpleName
        private val REGEX_PHONE = "^01(?:0|1|[6-9])-(\\d{3,4})-\\d{4}$".toRegex()
    }

    private lateinit var binding: FragmentRegisterVerificationBinding
    private lateinit var imm: InputMethodManager
    private lateinit var mCountDownTimer: CountDownTimer
    private var mRegister: HashMap<String, String> = hashMapOf()
    private var mPhoneNumber: String? = null
    private var mTimerRunning: Boolean = false
    private val mStartTimeInMillis: Long = 180000L
    private var mTimeLeftInMillis = mStartTimeInMillis


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_register_verification, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        Log.d(TAG, "mRegister => $mRegister")
        imm = context?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.showSoftInput(binding.inputPhone, 0)
        imm.showSoftInput(binding.inputAuth, 0)
//        initPhoneNumber()
        binding.btnRequestAuth.apply {
            isClickable = false
            mTimerRunning = true
            setOnClickListener(requestVerificationCode)
        }
        binding.layoutButtonDone.btnDone.setOnClickListener(nextView)
        binding.inputPhone.doAfterTextChanged { text ->
            if (mPhoneNumber.isNullOrEmpty() || mPhoneNumber != text.toString()) {
                checkPhoneNumber(text.toString())
            }
        }
        binding.inputAuth.doAfterTextChanged { text -> isDoneButton((text.toString().isNotEmpty() && text.toString().length == 6)) }
    }

    private val nextView = View.OnClickListener {
        Log.d(TAG, "click => next")
        mRegister[Constants.REQUEST_KEY_PHONE_NUMBER] = Commons.digitPhoneNumber(binding.inputPhone.text.toString())
        mRegister[Constants.REQUEST_KEY_VERIFICATION_CODE] = binding.inputAuth.text.toString()

        Log.d(TAG, "mRegister => $mRegister")
        RetrofitClient.getService().register(
            mRegister[Constants.REQUEST_KEY_USERNAME].toString(),
            mRegister[Constants.REQUEST_KEY_PASSWORD].toString(),
            mRegister[Constants.REQUEST_KEY_PASSWORD_CONFIRM].toString(),
            mRegister[Constants.REQUEST_KEY_NAME].toString(),
            mRegister[Constants.REQUEST_KEY_NICKNAME].toString(),
            mRegister[Constants.REQUEST_KEY_PHONE_NUMBER].toString(),
            mRegister[Constants.REQUEST_KEY_VERIFICATION_CODE].toString(),
            mRegister[Constants.REQUEST_KEY_EMAIL].toString()
        ).enqueue(object: Callback<Map<String, Any>> {
            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, Any>>, response: Response<Map<String, Any>>) {
                if (response.isSuccessful) {
                    Log.d(TAG, "response body => ${response.body()}")
                    login()
                } else {
                    toast("인증 번호가 일치하지 않습니다.")
                    Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                }
            }
        })
    }

    private fun login() {
        RetrofitClient.getService().login(
            Constants.REQUEST_KEY_GRANT_LOGIN,
            mRegister[Constants.REQUEST_KEY_USERNAME].toString(),
            mRegister[Constants.REQUEST_KEY_PASSWORD].toString()
        ).enqueue(object: Callback<Map<String, String>> {
            override fun onFailure(call: Call<Map<String, String>>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, String>>, response: Response<Map<String, String>>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    Log.d(TAG, "response body => ${response.body()}")
                    response.body()?.apply {
                        Preferences.token = this[Constants.EXTRA_KEY_TOKEN].toString()
                        Preferences.refresh = this[Constants.EXTRA_KEY_REFRESH_TOKEN].toString()
                        imm.hideSoftInputFromWindow(binding.inputPhone.windowToken, 0)
                        imm.hideSoftInputFromWindow(binding.inputAuth.windowToken, 0)
                        (activity as RegisterActivity).nextView(Constants.REGISTER_TYPE_DONE)
                    }
                }
            }
        })
    }

    private fun mTimerRunningStart() {
        Log.d(TAG, "click => mTimerRunningStart")
        if (mTimerRunning) startTimer()
        else Log.d(TAG, "click => mTimerRunning:$mTimerRunning")
    }

    private fun startTimer() {
        Log.d(TAG, "click => startTimer:$mTimeLeftInMillis")
        val value = binding.tvRequestAuth.text.toString()
        Log.d(TAG, "click => countText:$value")
        if (value == getString(R.string.content_button_re_request_auth)) {
            mTimeLeftInMillis = mStartTimeInMillis
            updateCountDownText()
        } else {
            mCountDownTimer = object  : CountDownTimer(mTimeLeftInMillis, 1000) {
                override fun onFinish() {
                    Log.d(TAG,"click => onFinish ")
                    // 종료 시 작동
                    mTimerRunning = false
                }

                override fun onTick(millisUntilFinished: Long) {
                    Log.d(TAG, "onTick => millisUntilFinished:$millisUntilFinished")
                    binding.tvRequestAuth.setText(R.string.content_button_re_request_auth)
                    mTimeLeftInMillis = millisUntilFinished
                    updateCountDownText()
                }
            }.start()
        }
        mTimerRunning = true
    }

    private fun updateCountDownText() {
        Log.d(TAG, "updateCountDownText()")
        val minutes = ((mTimeLeftInMillis / 1000) / 60).toInt()
        val seconds = ((mTimeLeftInMillis / 1000) % 60).toInt()
        val timeLeftFormatted = String.format(Locale.getDefault(),  "%02d:%02d", minutes, seconds)
        binding.tvCounter.text = timeLeftFormatted
        Log.d(TAG, "updateCountDownText => timeLeftFormatted:$timeLeftFormatted ")
    }

    private val requestVerificationCode = View.OnClickListener {
        mTimerRunningStart()
        binding.layoutInputAuth.isEnabled = true
        binding.inputAuth.requestFocus()
        Log.d(TAG, "click => requestVerificationCode")
        val phoneNumber = Commons.digitPhoneNumber(binding.inputPhone.text.toString())
        Log.d(TAG, "click => requestVerificationCode => $phoneNumber")
        RetrofitClient.getService().verificationCode(phoneNumber).enqueue(object: Callback<Map<String, Any>> {
            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, Any>>, response: Response<Map<String, Any>>) {
                if (response.isSuccessful) {
                    Log.d(TAG, "response body => ${response.body()}")

                } else {
                    Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                }
            }
        })
    }

    private fun initPhoneNumber() {
        val phoneNumber = (activity as RegisterActivity).getPhoneNumber()
        phoneNumber?.apply {
            binding.inputPhone.setText(this)
            binding.inputPhone.isEnabled = false
            isActiveButton(true)
        }
    }

    private fun checkPhoneNumber(text: String) {
        mPhoneNumber = text
        val phoneNumber = Commons.makePhoneNumber(text)
        Log.d(TAG, "phoneNumber => $phoneNumber")
        phoneNumber?.apply {
            binding.inputPhone.setText(this)
            binding.inputPhone.setSelection(binding.inputPhone.length())

            if (this.isEmpty() or this.matches(REGEX_PHONE).not()) isActiveButton(false)
            else isActiveButton(true)
        }
    }

    private fun isActiveButton(isActive: Boolean) {
        if (isActive) {
            binding.btnRequestAuth.apply {
                isClickable = true
                setCardBackgroundColor(ContextCompat.getColor(context, R.color.main_color))
            }
        } else {
            binding.btnRequestAuth.apply {
                isClickable = false
                setCardBackgroundColor(ContextCompat.getColor(context, R.color.gray))
            }
        }
    }

    private fun isDoneButton(isActive: Boolean) {
        if (isActive) {
            binding.layoutButtonDone.btnDone.apply {
                isClickable = true
                setCardBackgroundColor(ContextCompat.getColor(context, R.color.main_color))
            }
        } else {
            binding.layoutButtonDone.btnDone.apply {
                isClickable = false
                setCardBackgroundColor(ContextCompat.getColor(context, R.color.gray))
            }
        }
    }

    fun loadRegister(data: Map<String, String>) {
        mRegister = data as HashMap<String, String>
    }

}