package com.gongmanse.app.activities

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.telephony.TelephonyManager
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ActivityRegisterBinding
import com.gongmanse.app.fragments.register.RegisterDoneFragment
import com.gongmanse.app.fragments.register.RegisterFormFragment
import com.gongmanse.app.fragments.register.RegisterPrivacyFragment
import com.gongmanse.app.fragments.register.RegisterVerificationFragment
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import kotlinx.android.synthetic.main.activity_register.*
import org.jetbrains.anko.alert
import org.jetbrains.anko.noButton
import org.jetbrains.anko.yesButton

class RegisterActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = RegisterActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityRegisterBinding
    private lateinit var currentFragment: Fragment
    private val registerPrivacyFragment by lazy { RegisterPrivacyFragment() }
    private val registerFormFragment by lazy { RegisterFormFragment() }
    private val registerVerificationFragment by lazy { RegisterVerificationFragment() }
    private val registerDoneFragment by lazy { RegisterDoneFragment() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_register)
        initView()
    }

    private fun initView() {
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_REGISTER
        val transaction = supportFragmentManager.beginTransaction()
        transaction.add(R.id.view_content, registerPrivacyFragment, registerPrivacyFragment.javaClass.simpleName)
        transaction.add(R.id.view_content, registerFormFragment, registerFormFragment.javaClass.simpleName)
        transaction.add(R.id.view_content, registerVerificationFragment, registerVerificationFragment.javaClass.simpleName)
        transaction.add(R.id.view_content, registerDoneFragment, registerDoneFragment.javaClass.simpleName)
        transaction.hide(registerPrivacyFragment)
        transaction.hide(registerFormFragment)
        transaction.hide(registerVerificationFragment)
        transaction.hide(registerDoneFragment)
        transaction.commit()
        nextView(Constants.REGISTER_TYPE_PRIVACY)
    }

    private fun setFragment(fragment: Fragment) {
        val transaction = supportFragmentManager.beginTransaction()
        if (::currentFragment.isInitialized) {
            transaction.hide(currentFragment)
        }
        transaction.show(fragment).commit()
        currentFragment = fragment
    }

    // 다음
    fun nextView(position: Int) {
        Log.d(TAG, "nextView position => $position")
        when(position) {
            // 이용약관
            Constants.REGISTER_TYPE_PRIVACY -> {
                setFragment(registerPrivacyFragment)
                tv_content_title.text = "이용약관"
                tv_content_index.text = "1/4"
                pb_progress.progress = 25
            }
            // 회원가입
            Constants.REGISTER_TYPE_FORM -> {
                setFragment(registerFormFragment)
                tv_content_title.text = "회원가입"
                tv_content_index.text = "2/4"
                pb_progress.progress = 50
            }
            // 본인인증
            Constants.REGISTER_TYPE_VERIFICATION -> {
                setFragment(registerVerificationFragment)
                tv_content_title.text = "본인인증"
                tv_content_index.text = "3/4"
                pb_progress.progress = 75
            }
            // 가입완료
            Constants.REGISTER_TYPE_DONE -> {
                setFragment(registerDoneFragment)
                tv_content_title.text = "가입완료"
                tv_content_index.text = "4/4"
                pb_progress.progress = 100
            }
        }
    }

    fun nextVerification(data: Map<String, String>) {
        Log.d(TAG, "nextVerification data => $data")
        setFragment(registerVerificationFragment)
        registerVerificationFragment.loadRegister(data)
        tv_content_title.text = "본인인증"
        tv_content_index.text = "3/4"
        pb_progress.progress = 75
    }

    // 완료
    fun done() {
        setResult(Activity.RESULT_OK)
        finish()
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.btn_close -> Commons.close(this)
        }
    }

    override fun onBackPressed() {
        Log.d(TAG, "onBackPressed()")
        alert(message = "회원가입을 종료하시겠습니까?") {
            yesButton { finish() }
            noButton { it.dismiss() }
        }.show()
    }

    @SuppressLint("HardwareIds")
    fun getPhoneNumber(): String? {
        val msg = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        if (ActivityCompat.checkSelfPermission(this@RegisterActivity, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED
            && ActivityCompat.checkSelfPermission(this@RegisterActivity, Manifest.permission.READ_PHONE_NUMBERS) != PackageManager.PERMISSION_GRANTED
            && ActivityCompat.checkSelfPermission(this@RegisterActivity, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            return null
        }
        return replacePhoneNumber(msg.line1Number)
    }

    private fun replacePhoneNumber(number: String?): String? {
        if (number == null) return null
        var phone = number
        if (number.startsWith("+82")) {
            phone = number.replace("+82", "0")
        }
        return Commons.makePhoneNumber(phone)
    }

}