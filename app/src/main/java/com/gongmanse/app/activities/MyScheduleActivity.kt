package com.gongmanse.app.activities

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.FragmentTransaction
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ActivityMyScheduleBinding
import com.gongmanse.app.fragments.schedule.MyScheduleCalendarFragment
import com.gongmanse.app.utils.Constants
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class MyScheduleActivity : AppCompatActivity() , View.OnClickListener {

    companion object {
        private val TAG = MyScheduleActivity::class.java.simpleName
    }

    private lateinit var binding : ActivityMyScheduleBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this,R.layout.activity_my_schedule)
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_SCHEDULE
        initView()
    }

    override fun onClick(v: View?) {
        when(v?.id){
            R.id.btn_close -> onBackPressed()
        }
    }

    fun initView(){
        val fm : FragmentTransaction = supportFragmentManager.beginTransaction()
        fm.replace(R.id.fragment_space, MyScheduleCalendarFragment()).commit()
    }

    fun click(item: MenuItem) {
        startActivity(intentFor<MyScheduleSettingActivity>().singleTop())
    }


}