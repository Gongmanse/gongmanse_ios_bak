package com.gongmanse.app.feature.member

import androidx.databinding.ObservableField
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.member.Member
import com.gongmanse.app.data.network.member.MemberRepository
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import com.gongmanse.app.utils.SingleLiveEvent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MemberViewModel(private val memberRepository: MemberRepository?): ViewModel() {

    private val _currentMember = SingleLiveEvent<Member?>()
    private val _token = SingleLiveEvent<String?>()
    private val _result = SingleLiveEvent<Int>()

    var username = ObservableField<String?>()
    var password = ObservableField<String?>()

    val currentMember: SingleLiveEvent<Member?>
        get() = _currentMember

    val token: SingleLiveEvent<String?>
        get() = _token

    val result: SingleLiveEvent<Int>
        get() = _result

    private fun getUsername(): String {
        return username.get().toString()
    }

    private fun getPassword(): String {
        return password.get().toString()
    }

    fun refreshToken(){
        CoroutineScope(Dispatchers.IO).launch {
            memberRepository?.getRefreshToken(Preferences.refresh)?.let { response ->
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Commons.saveToken(this.toString())
                    }
                }
            }
        }
    }

    fun login() {
        CoroutineScope(Dispatchers.IO).launch {
            memberRepository?.getToken(getUsername(), getPassword())?.let { response ->
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        Preferences.token = body.token ?: ""
                        Preferences.refresh = body.refreshToken ?: ""
                    }
                }
                _token.postValue(Preferences.token)
                _result.postValue(response.code())
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

}