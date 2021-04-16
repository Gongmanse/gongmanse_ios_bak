package com.gongmanse.app.feature.main.teacher

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.data.network.teacher.TeacherRepository

class TeacherViewModelFactory(private val teacherRepository: TeacherRepository): ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return modelClass.getConstructor(TeacherRepository::class.java).newInstance(teacherRepository)
    }

}