package com.gongmanse.app.activities

import android.os.Bundle
import android.os.CountDownTimer
import android.text.Editable
import android.text.InputFilter
import android.text.InputType
import android.text.TextWatcher
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityFindIdBinding
import com.gongmanse.app.model.Data
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import kotlinx.android.synthetic.main.item_date.view.*
import okhttp3.ResponseBody
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*

@Suppress("DEPRECATION")
class FindIdActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = FindIdActivity::class.java.simpleName
        private const val REGEX_EMAIL = "[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*\\.[a-zA-Z]{2,3}"
        private const val REGEX_PHONE = "^01(?:0|1|[6-9])(\\d{3,4})(\\d{4})"
        private const val CODE_00 = "00" // 존재하지 않는 사용자
        private const val CODE_01 = "01" // 존재하는 사용자
        private const val CODE_10 = "10" // 존재하지만 아이디 일치하지 않음
        private const val CODE_11 = "11" // 존재하면서 아이디 일치
    }

    private lateinit var binding: ActivityFindIdBinding
    private var receiverType: String = Constants.RECEIVER_TYPE_EMAIL
    private var isActiveRequest: Boolean = false
    private var isActiveDone: Boolean = false
    private var responseKey: String? = null
    private var userName: String = ""
    private var userReceiver: String = ""
    private var mCountDownTimer: CountDownTimer? = null
    private var mTimerRunning: Boolean = false
    private val mStartTimeInMillis: Long = 180000L
    private var mTimeLeftInMillis = mStartTimeInMillis

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_find_id)
        initView()
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.btn_close -> Commons.close(this)
            R.id.btn_request_auth -> {
                mTimerRunning = true
                requestHasRegister()
            }
        }
    }

    private fun initView() {
        mStartTimeInMillis.setupTimer()
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_FIND_ID
        setRequestView(false)
        binding.radioGroup.setOnCheckedChangeListener { _, checkedId ->
            mTimerRunning = false
            resetView(checkedId)
        }
        binding.inputAuth.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {}
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

                val isChecked = s.toString().length > 9
                Log.d(TAG, "isChecked => $isChecked\nisActiveRequest => $isActiveRequest")

                var isRegex = false
                if (receiverType == Constants.RECEIVER_TYPE_EMAIL) {
                    if (s != null) isRegex = !s.matches(REGEX_EMAIL.toRegex()).not() else Log.v(TAG, "s is null")
                } else {
                    if (s != null) isRegex = !s.matches(REGEX_PHONE.toRegex()).not() else Log.v(TAG, "s is null")
                }

                setRequestView(isChecked && isRegex)
//                if (isChecked && isRegex != isActiveRequest) {
//                    setRequestView(isChecked)
//                    isActiveRequest = isChecked
//                }
            }
        })
        binding.inputAuthNumber.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {}
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val isChecked = s.toString().trim().isNotEmpty()
                Log.d(TAG, "isChecked => $isChecked\nisActiveDone => $isActiveDone")
                if (isChecked != isActiveDone) {
                    setDoneView(isChecked)
                    isActiveDone = isChecked
                }
            }
        })
    }

    private fun setRequestView(isChecked: Boolean) {
        if (!isChecked) {
            binding.btnRequestAuth.apply {
                isClickable = false
                mTimerRunning = false
                setCardBackgroundColor(ContextCompat.getColorStateList(this@FindIdActivity, R.color.gray))
            }
        } else {
            binding.btnRequestAuth.apply {
                isClickable = true
                mTimerRunning = true
                setCardBackgroundColor(ContextCompat.getColorStateList(this@FindIdActivity, R.color.main_color))
            }
        }
    }

    private fun setDoneView(isChecked: Boolean) {
        if (!isChecked) {
            binding.layoutButtonDone.btnDone.apply {
                isClickable = false
                setCardBackgroundColor(ContextCompat.getColorStateList(this@FindIdActivity, R.color.gray))
                setOnClickListener(null)
            }
        } else {
            binding.layoutButtonDone.btnDone.apply {
                isClickable = true
                setCardBackgroundColor(ContextCompat.getColorStateList(this@FindIdActivity, R.color.main_color))
                setOnClickListener { checkAuthNumber() }
            }
        }
    }

    // 인증번호 확인 및 페이지 이동
    private fun checkAuthNumber() {
        if (responseKey != binding.inputAuthNumber.text.toString()) {
            toast("인증번호가 일치하지 않습니다.")
            return
        }
        RetrofitClient.getService().findRecoverId(receiverType, userReceiver, userName).enqueue(object : Callback<Map<String, String>> {
            override fun onFailure(call: Call<Map<String, String>>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, String>>, response: Response<Map<String, String>>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.d(TAG, "onResponse => $this -> ${this["key"]}")
                        val username = this["sUsername"]
                        startActivity(intentFor<ResultFindIdActivity>(Constants.EXTRA_KEY_USER_NAME to username).singleTop())
                        finish()
                    }
                }
            }
        })
    }

    // 인증번호 요청
    private fun requestAuthNumber() {
        Log.d(TAG, "인증번호 요청")
        binding.apply {
            mTimerRunningStart()
            layoutInputAuthNumber.isEnabled = true
//            tvCounter.setTextColor(ContextCompat.getColor(this@FindIdActivity, R.color.light_black2))
            tvCounter.setTextColor(ContextCompat.getColor(this@FindIdActivity, R.color.sub_color7))
            inputAuthNumber.requestFocus()
            userReceiver = inputAuth.text.toString()
            userName = inputName.text.toString()
            Log.e(TAG, "receiverType:$receiverType, userReceiver:$userReceiver, userName:$userName")
            RetrofitClient.getService().requestAuthNumber(receiverType, userReceiver, userName).enqueue(object : Callback<Map<String, String>> {
                override fun onFailure(call: Call<Map<String, String>>, t: Throwable) {
                    Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(call: Call<Map<String, String>>, response: Response<Map<String, String>>) {
                    if (response.isSuccessful) {
                        response.body()?.apply {
                            Log.d(TAG, "onResponse => $this -> ${this["key"]}")
                            responseKey = this["key"]
                        }
                    } else {
                        Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                    }
                }
            })
        }
    }

    private fun mTimerRunningStart() {
        Log.d(TAG, "click => mTimerRunningStart")
        if (mTimerRunning) startTimer()
        else {
            mCountDownTimer?.cancel()
            mStartTimeInMillis.setupTimer()
        }
    }

    private fun startTimer() {
        val value = binding.tvRequestAuth.text.toString()
        Log.d(TAG, "click => countText:$value")
        if (value == getString(R.string.content_button_re_request_auth)) {
            mTimeLeftInMillis = mStartTimeInMillis
            mCountDownTimer?.cancel()
            mStartTimeInMillis.setupTimer()
            mCountDownTimer?.start()

        } else {
            mCountDownTimer?.start()
        }
        mTimerRunning = true
    }


    private fun updateCountDownText() {
        val minutes = ((mTimeLeftInMillis / 1000) / 60).toInt()
        val seconds = ((mTimeLeftInMillis / 1000) % 60).toInt()
        val timeLeftFormatted = String.format(Locale.getDefault(), "%02d:%02d", minutes, seconds)
        binding.tvCounter.text = timeLeftFormatted
    }

    // 화면 리셋
    private fun resetView(checkedId: Int) {
        when (checkedId) {
            R.id.rb_find_by_email -> {
                Log.d(TAG, "이메일로 찾기")
                receiverType = Constants.RECEIVER_TYPE_EMAIL
                binding.layoutInputAuth.apply {
                    startIconDrawable = ContextCompat.getDrawable(context, R.drawable.ic_email_off)
                    hint = getString(R.string.content_hint_email)
                    binding.inputAuth.inputType = InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS
                    setMaxLength(null)
                }
            }
            R.id.rb_find_by_phone -> {
                Log.d(TAG, "휴대전화로 찾기")
                receiverType = Constants.RECEIVER_TYPE_PHONE
                binding.layoutInputAuth.apply {
                    startIconDrawable = ContextCompat.getDrawable(context, R.drawable.ic_phone_number_off)
                    hint = getString(R.string.content_hint_phone)
                    binding.inputAuth.inputType = InputType.TYPE_CLASS_PHONE
                    setMaxLength(11)
                }
            }
        }
        binding.apply {
            if (!mTimerRunning) {
                Log.d(TAG, "resetTimer mTimerRunning => $mTimerRunning")
                mTimerRunning = false
                mTimeLeftInMillis = mStartTimeInMillis
                mCountDownTimer?.cancel()
                tvCounter.text = getString(R.string.content_text_counter)
                mStartTimeInMillis.setupTimer()
            } else Log.d(TAG, "resetTimer mTimerRunning => $mTimerRunning")

            tvRequestAuth.setText(R.string.content_button_request_auth)
            layoutInputAuthNumber.isEnabled = false
            btnRequestAuth.isClickable = false
            btnRequestAuth.setCardBackgroundColor(ContextCompat.getColor(this@FindIdActivity, R.color.gray))
            tvCounter.setTextColor(ContextCompat.getColor(this@FindIdActivity, R.color.gray))
            tvCounter.text = getString(R.string.content_text_counter)
            inputAuth.text?.clear()
            inputAuthNumber.text?.clear()
            inputName.requestFocus()
        }
    }

    // 최대 입력 제한 설정
    private fun setMaxLength(length: Int?) {
        binding.inputAuth.filters = if (length == null) Array<InputFilter>(1) { InputFilter.LengthFilter(Int.MAX_VALUE) } else Array<InputFilter>(1) { InputFilter.LengthFilter(length) }
    }

    private fun Long.setupTimer() {
        mCountDownTimer = object : CountDownTimer(this, 1000) {
            override fun onFinish() {
                Log.d(TAG, "click => onFinish ")
                // 종료 시 작동
                mTimerRunning = false
            }

            override fun onTick(millisUntilFinished: Long) {
                binding.tvRequestAuth.setText(R.string.content_button_re_request_auth)
                mTimeLeftInMillis = millisUntilFinished
                updateCountDownText()
            }
        }
    }

    // 계정 유무 확인
    private fun requestHasRegister() {
        val userName = binding.inputName.text.toString()
        val userAuth = binding.inputAuth.text.toString()
        RetrofitClient.getService().findRegister(
            userName,
            if (receiverType == Constants.RECEIVER_TYPE_PHONE) userAuth else null,
            if (receiverType == Constants.RECEIVER_TYPE_EMAIL) userAuth else null,
            null
        ).enqueue(object : Callback<Data> {
            override fun onFailure(call: Call<Data>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Data>, response: Response<Data>) {
                if (response.isSuccessful) {
                    response.body()?.let {
                        Log.d(TAG, "onResponse => $it")
                        when (it.data) {
                            CODE_00 -> Toast.makeText(this@FindIdActivity, "존재하지 않는 사용자입니다.", Toast.LENGTH_SHORT).show()
                            CODE_01 -> {
                                if (receiverType == Constants.RECEIVER_TYPE_EMAIL) {
                                    requestEmailAuthNumber()
                                } else {
                                    requestAuthNumber()
                                }
                            }
                        }
                    }
                } else {
                    Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                }
            }
        })
    }

    // 인증번호 요청
    private fun requestEmailAuthNumber() {
        Log.d(TAG, "인증번호 요청")
        binding.apply {
            mTimerRunningStart()
            layoutInputAuthNumber.isEnabled = true
            tvCounter.setTextColor(ContextCompat.getColor(this@FindIdActivity, R.color.sub_color7))
            inputAuthNumber.requestFocus()
            userReceiver = inputAuth.text.toString()
            userName = inputName.text.toString()
            Log.e(TAG, "receiverType:$receiverType, userReceiver:$userReceiver, userName:$userName")
            RetrofitClient.getService().requestEmailAuthNumber(receiverType, userReceiver, userName).enqueue(object : Callback<ResponseBody> {
                    override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                        Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                    }

                    override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                        if (response.isSuccessful) {
                            response.body()?.apply {
                                Log.d(TAG, "onResponse => $this")
                                val str = this.string()
                                Log.d(TAG, "str => $str")
                                val indexStart = str.lastIndexOf('[')
                                val indexEnd = str.lastIndexOf(']')
                                Log.d(TAG, "Keyword indexStart => $indexStart")
                                Log.d(TAG, "Keyword indexEnd => $indexEnd")
                                if (indexStart != -1 && indexEnd != -1) {
                                    val number = str.substring(indexStart.plus(1), indexEnd)
                                    Log.d(TAG, "onResponse Keyword => $number")
                                    responseKey = number
                                }
                            }
                        } else {
                            Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                        }
                    }
            })
        }
    }

}