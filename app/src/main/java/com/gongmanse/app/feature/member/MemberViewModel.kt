package com.gongmanse.app.feature.member

import android.util.Log
import androidx.databinding.ObservableField
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.member.Member
import com.gongmanse.app.data.network.member.MemberRepository
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import com.gongmanse.app.utils.SingleLiveEvent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch


class MemberViewModel(private val memberRepository: MemberRepository?): ViewModel() {

    private val _currentMember = SingleLiveEvent<Member?>()
    private val _token = SingleLiveEvent<String?>()
    private val _resultCode = SingleLiveEvent<Int>()
    private val _disposables = SingleLiveEvent<Boolean>()

    var username = ObservableField<String?>() // 아이디
    var password = ObservableField<String?>() // 비밀번호
    var passwordConfirm = ObservableField<String?>() // 비밀번호 확인
    var profile = ObservableField<String?>() // 프로필
    var name = ObservableField<String?>() // 이름
    var nickname = ObservableField<String?>() // 닉네임
    var email = ObservableField<String?>() // 이메일

    var passwordError = ObservableField<String?>() // 비밀번호 에러 메시지
    var passwordConfirmError = ObservableField<String?>() // 비밀번호 확인 에러 메시지
    var nicknameError = ObservableField<String?>() // 닉네임 에러 메시지
    var emailError = ObservableField<String?>() // 이메일 에러 메시지

    val currentMember: SingleLiveEvent<Member?>
        get() = _currentMember

    val token: SingleLiveEvent<String?>
        get() = _token

    val resultCode: SingleLiveEvent<Int>
        get() = _resultCode

    val disposables: SingleLiveEvent<Boolean>
        get() = _disposables

    private fun getUsername(): String {
        return username.get().toString()
    }

    private fun getPassword(): String {
        return password.get().toString()
    }

    fun refreshToken(){
        CoroutineScope(Dispatchers.IO).launch {
            memberRepository?.getToken(Preferences.refresh)?.let { response ->
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        Log.v(TAG, "refresh token => ${body.token}")
                        Preferences.token = body.token ?: Constants.Init.INIT_STRING
                    }
                }
            }
        }
    }

    fun login() {
        CoroutineScope(Dispatchers.IO).launch {
            memberRepository?.getToken(getUsername(), getPassword())?.let { response ->
                Log.v(TAG, "result code => ${response.code()}")
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        Log.v(TAG, "login token => ${body.token}")
                        Preferences.token = body.token ?: Constants.Init.INIT_STRING
                        Preferences.refresh = body.refreshToken ?: Constants.Init.INIT_STRING
                    }
                }
                _token.postValue(Preferences.token)
                _resultCode.postValue(response.code())
            }
        }
    }

    fun logout() {
        Preferences.token = Constants.Init.INIT_STRING
        _token.value = Preferences.token
        _currentMember.value = null
    }

    fun getProfile() {
        CoroutineScope(Dispatchers.IO).launch {
            memberRepository?.getProfile()?.let { response ->
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        _currentMember.postValue(body)
                        username.set(body.memberBody.username)
                        name.set(body.memberBody.name)
                        nickname.set(body.memberBody.nickname)
                        email.set(body.memberBody.email)
                        profile.set(body.memberBody.profile)
                    }
                } else {
                    _currentMember.postValue(null)
                }
            }
        }
    }

    fun setProfile() {
        CoroutineScope(Dispatchers.IO).launch {

        }
    }

    private fun passwordConfirmCheck() {
        passwordConfirm.get().apply {
            when {
                isNullOrEmpty() -> {
                    passwordConfirmError.set(null)
                }
                password.get().toString() != passwordConfirm.get().toString() -> {
                    passwordConfirmError.set("비밀번호가 일치하지 않습니다.")
                }
                else -> {
                    passwordConfirmError.set(null)
                }
            }
        }
    }

    fun onPasswordChanged(s: CharSequence) {
        password.set(s.toString())
        passwordConfirmCheck()
        password.get().apply {
            when {
                isNullOrEmpty() -> {
                    passwordError.set(null)
                }
                (length !in 8..16).or(matches(Constants.Regex.REGEX_PASSWORD.toRegex()).not()) -> {
                    passwordError.set("8~16자의 영문,숫자,특수문자를 사용해주세요.")
                }
                else -> {
                    passwordError.set(null)
                }
            }
        }
    }

    fun onPasswordConfirmChanged(s: CharSequence) {
        passwordConfirm.set(s.toString())
        passwordConfirmCheck()
    }

    fun onNicknameChanged(s: CharSequence) {
        nickname.set(s.toString())
        nickname.get().apply {
            when {
                isNullOrEmpty() -> {
                    nicknameError.set(null)
                }
                (length !in 2..12).or(matches(Constants.Regex.REGEX_NICKNAME.toRegex()).not()) -> {
                    nicknameError.set("2 ~ 12자를 사용하세요.")
                }
                else -> {
                    nicknameError.set(null)
                }
            }
        }
    }

    fun onEmailChanged(s: CharSequence) {
        email.set(s.toString())
        email.get().apply {
            when {
                isNullOrEmpty() -> {
                    emailError.set(null)
                }
                matches(Constants.Regex.REGEX_EMAIL.toRegex()).not() -> {
                    emailError.set("이메일 형식에 맞게 입력해주세요.")
                }
                else -> {
                    emailError.set(null)
                }
            }
        }
    }

    companion object {
        private val TAG = MemberViewModel::class.java.simpleName
    }

}