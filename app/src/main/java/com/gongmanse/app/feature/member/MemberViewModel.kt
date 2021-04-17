package com.gongmanse.app.feature.member

import android.util.Log
import androidx.databinding.ObservableField
import androidx.databinding.adapters.TextViewBindingAdapter
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
    var profile = ObservableField<String?>(currentMember.value?.memberBody?.profile) // 프로필
    var nickname = ObservableField<String?>(currentMember.value?.memberBody?.nickname) // 닉네임
    var email = ObservableField<String?>(currentMember.value?.memberBody?.email) // 이메일

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

    fun onPasswordChanged(s: CharSequence) {
        password.set(s.toString())
    }

    fun onPasswordConfirmChanged(s: CharSequence) {
        passwordConfirm.set(s.toString())
        val check = password.get().toString() == passwordConfirm.get().toString()
        _disposables.postValue(check)
    }

    companion object {
        private val TAG = MemberViewModel::class.java.simpleName
    }

}