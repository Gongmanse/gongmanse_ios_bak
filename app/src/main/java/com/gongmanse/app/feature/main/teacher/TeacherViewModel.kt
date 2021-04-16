package com.gongmanse.app.feature.main.teacher


import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.gongmanse.app.data.model.teacher.TeacherBody
import com.gongmanse.app.data.network.teacher.TeacherRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class TeacherViewModel(private val teacherRepository: TeacherRepository) : ViewModel() {

    private val _currentValue = MutableLiveData<ArrayList<TeacherBody>>()

    val currentValue : LiveData<ArrayList<TeacherBody>>
        get() = _currentValue

    fun liveDataClear(){
        _currentValue.value?.clear()
    }

    //과목별
    fun getTeacher(grade : String?, offset : Int?, limit : Int?){
        Log.d("TAG", "$grade : $offset : $limit  ")
        CoroutineScope(Dispatchers.IO).launch {
            try {
                teacherRepository.getTeacher(grade, offset, limit).apply {
                    if (this.isSuccessful) {
                        Log.d("ititit","${this}")
                        this.body()?.let { response ->
                            response.teacherBody.let {
                                _currentValue.postValue(it)
                            }
                        }
                    }
                }
            }catch (e : Exception){
                Log.e("error" , "$e")
            }
        }
    }
}

