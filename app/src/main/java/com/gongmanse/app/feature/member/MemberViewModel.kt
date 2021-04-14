package com.gongmanse.app.feature.member

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.member.Member
import com.gongmanse.app.data.network.member.MemberRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MemberViewModel(private val memberRepository: MemberRepository): ViewModel() {

    companion object {
        private val TAG = MemberViewModel::class.java.simpleName
    }

    private val _currentValue = MutableLiveData<Member>()

    val currentValue: LiveData<Member>
        get() = _currentValue

    fun getProfile() {
        CoroutineScope(Dispatchers.IO).launch {
            memberRepository.getProfile().let { response ->
                if (response.isSuccessful) {
                    response.body()?.let { body ->
                        _currentValue.postValue(body)
                    }
                }
            }
        }
    }

}