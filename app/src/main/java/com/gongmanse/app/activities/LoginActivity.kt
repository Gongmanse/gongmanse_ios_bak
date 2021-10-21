package com.gongmanse.app.activities

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.model.SettingInfo
import com.gongmanse.app.model.UserData
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.android.synthetic.main.activity_login.*
import okhttp3.ResponseBody
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.startActivity
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.lang.reflect.Type

class LoginActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = LoginActivity::class.java.simpleName
        private const val REQUEST_CODE = 100
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.btn_close -> Commons.close(this)
            R.id.btn_login -> login()
            R.id.btn_find_by_id -> findId()
            R.id.btn_find_by_password -> findPassword()
            R.id.btn_sign_up -> signUp()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode != Activity.RESULT_OK) {
            return
        }
        if (requestCode == REQUEST_CODE) {
            Log.v(TAG, "RESULT!!!")
            setResult(Activity.RESULT_OK)
            finish()
        }
    }

    // 로그인
    private fun login() {
        Log.v(TAG, "onClick => 로그인")
        RetrofitClient.getService().login("password", input_id.text.toString(), input_password.text.toString()).enqueue(object : Callback<Map<String, String>> {
            override fun onFailure(call: Call<Map<String, String>>, t: Throwable) {
                Log.v(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, String>>, response: Response<Map<String, String>>) {
                if (response.isSuccessful) {
                    Log.v(TAG, "response body => ${response.body()}")
                    response.body()?.apply {
                        Preferences.token = this[Constants.EXTRA_KEY_TOKEN].toString()
                        Preferences.refresh = this[Constants.EXTRA_KEY_REFRESH_TOKEN].toString()
                        Log.v(TAG,"Preferences.token => ${Preferences.token}")
                        sendRegistrationToServer()
                        loadSettings()
                    }
                } else {
                    Log.v(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                    toast(Constants.TOAST_MESSAGE_LOGIN)
                }
            }
        })
    }

    // 아이디 찾기
    private fun findId() {
        Log.v(TAG, "onClick => 아이디 찾기")
        startActivity<FindIdActivity>()
    }

    // 비밀번호 찾기
    private fun findPassword() {
        Log.v(TAG, "onClick => 비밀번호 찾기")
        startActivity<FindPasswordActivity>()
    }

    // 회원가입
    private fun signUp() {
        Log.v(TAG, "onClick => 회원가입")
        startActivityForResult(intentFor<RegisterActivity>(), REQUEST_CODE)
    }

    // 토큰 정보 서버에 업데이트
    private fun sendRegistrationToServer() {
        val token = Preferences.fcmToken
        Log.v(TAG, "sendRegistrationTokenToServer($token)")
        if (Preferences.token.isNotEmpty()) {
            RetrofitClient.getService().getUserId(Preferences.token).enqueue(object : Callback<UserData> {
                override fun onFailure(call: Call<UserData>, t: Throwable) {
                    Log.v(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(call: Call<UserData>, response: Response<UserData>) {
                    if (response.isSuccessful) {
                        Log.d(TAG, "response body => ${response.body()}")
                        response.body()?.userId?.let { sendTokenToServer(it, token) }
                    } else {
                        Log.v(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                    }
                }
            })
        } else {
            Log.v(TAG, "Failed Preference.Token is null.")
        }
    }

    private fun sendTokenToServer(userId: String, token: String) {
        RetrofitClient.getService().registerFcmToken(token, userId, "Android").enqueue(object : Callback<ResponseBody> {
            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                Log.v(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                if (response.isSuccessful) {
                    Log.v(TAG, "response body => ${response.body()}")
                } else {
                    Log.v(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                }
            }
        })
    }

    private fun loadSettings() {
        Log.v(TAG, "onClick => loadSettings")
        RetrofitClient.getService().getSettingInfo(Preferences.token).enqueue(object : Callback<Map<String, Any>> {
            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Map<String, Any>>, response: Response<Map<String, Any>>) {
                Log.i(TAG, "onResponseBody => ${response.body()}")
                if (response.isSuccessful) {
                    response.body()?.let {
                        val type: Type = object : TypeToken<SettingInfo>() {}.type
                        val jsonResult = Gson().toJson(it["data"])
                        val list = Gson().fromJson<SettingInfo>(jsonResult, type)
                        Log.v(TAG, "SettingInfo => $list")

                        // 학년
                        Commons.updatePreferencesGrade(list.grade)

                        // 과목
                        Commons.updatePreferencesSubject(list.subject)

                        // 과목 번호 ( 전체: 38 )
                        val subjectAllNumber = 38
                        Preferences.subjectId  = when(list.subjectId) {
                            Constants.CONTENT_VALUE_ALL_SUBJECT -> subjectAllNumber
                            "38" -> subjectAllNumber
                            null -> subjectAllNumber
                            else -> list.subjectId.toInt()
                        }

                        Log.v(TAG, "Subject -> id:${Preferences.subjectId}, title:${Preferences.subject}, grade:${Preferences.grade}")
                        setResult(Activity.RESULT_OK)
                        finish()

                    }
                }
            }
        })
    }

}