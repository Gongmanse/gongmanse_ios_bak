package com.gongmanse.app.feature.member

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
    private val _result = SingleLiveEvent<Int>()

    val currentMember: SingleLiveEvent<Member?>
        get() = _currentMember

    val token: SingleLiveEvent<String?>
        get() = _token

    val result: SingleLiveEvent<Int>
        get() = _result

    fun login(username: String, password: String) {
        CoroutineScope(Dispatchers.IO).launch {
            memberRepository?.getToken(username, password)?.let { response ->
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
        Preferences.token = Constants.EMPTY_STRING
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