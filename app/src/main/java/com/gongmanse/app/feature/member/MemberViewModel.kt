package com.gongmanse.app.feature.member

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.member.Member
import com.gongmanse.app.data.network.member.MemberRepository
import com.gongmanse.app.utils.Preferences
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MemberViewModel(private val memberRepository: MemberRepository): ViewModel() {

    private val _currentValue = MutableLiveData<Member?>()
    private val _token = MutableLiveData<String?>()
    private val _result = MutableLiveData<Int>()

    val currentValue: LiveData<Member?>
        get() = _currentValue

    val token: LiveData<String?>
        get() = _token

    val result: LiveData<Int>
        get() = _result

    fun login(username: String, password: String) {
        CoroutineScope(Dispatchers.IO).launch {
            memberRepository.getToken(username, password).let { response ->
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        Preferences.token = body.token ?: ""
                        Preferences.refresh = body.refreshToken ?: ""
                        _token.postValue(Preferences.token)
                    }
                }
                _result.postValue(response.code())
            }
        }
    }

    fun logout() {
        Preferences.token = ""
        _token.value = Preferences.token
        _currentValue.value = null
    }

    fun getProfile() {
        CoroutineScope(Dispatchers.IO).launch {
            memberRepository.getProfile().let { response ->
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        _currentValue.postValue(body)
                    }
                } else {
                    _currentValue.postValue(null)
                }
            }
        }
    }

}