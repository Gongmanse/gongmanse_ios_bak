package com.gongmanse.app.feature.member

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.data.network.member.MemberRepository

class MemberViewModelFactory(private val memberRepository: MemberRepository): ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return modelClass.getConstructor(MemberRepository::class.java).newInstance(memberRepository)
    }

}