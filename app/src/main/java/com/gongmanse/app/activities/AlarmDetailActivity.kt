package com.gongmanse.app.activities

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.gongmanse.app.R

class AlarmDetailActivity : AppCompatActivity() {

    companion object {
        private val TAG = AlarmDetailActivity::class.java.simpleName
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_alarm_detail)

    }
}