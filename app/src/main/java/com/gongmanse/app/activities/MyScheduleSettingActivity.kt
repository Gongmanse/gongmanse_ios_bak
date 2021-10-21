package com.gongmanse.app.activities

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityMyScheduleSettingBinding
import com.gongmanse.app.fragments.schedule.MyScheduleCalendarFragment
import com.gongmanse.app.model.Schedule
import com.gongmanse.app.model.ScheduleData
import com.gongmanse.app.model.ScheduleSetting
import com.gongmanse.app.model.ScheduleSettingData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import okhttp3.ResponseBody
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

/**
 * 스위치 컨트롤
 */

class MyScheduleSettingActivity : AppCompatActivity() , View.OnClickListener{

    companion object {
        private val TAG = MyScheduleSettingActivity::class.java.simpleName
    }

    private lateinit var binding : ActivityMyScheduleSettingBinding
    private var items = arrayListOf<ScheduleSettingData>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this,R.layout.activity_my_schedule_setting)
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_SCHEDULE_SETTING
        initData()
    }
    private fun initData(){
        getSetting()
    }

    private fun initView(){
        binding.apply {
            swScheduleMy.isChecked = Preferences.scheduleMy == 1
            swScheduleCeremony.isChecked = Preferences.scheduleCeremony == 1
            swScheduleEvent.isChecked = Preferences.scheduleEvent == 1
        }
        swAllControl()
    }
    private fun swAllControl(){
        binding.apply {
            if(!swScheduleMy.isChecked || !swScheduleCeremony.isChecked || !swScheduleEvent.isChecked){
                swScheduleAll.isChecked = false
            }
            if(swScheduleMy.isChecked && swScheduleCeremony.isChecked && swScheduleEvent.isChecked){
                switchAll(true)
            }
        }
    }

    override fun onBackPressed() {
        setPreference()
        putSetting()
        super.onBackPressed()
    }

    override fun onClick(v: View?) {
        when(v?.id){
            R.id.btn_close -> {
                setPreference()
                putSetting()
                onBackPressed()
            }
            R.id.sw_schedule_all ->{
                switchAll(binding.swScheduleAll.isChecked)
            }
            R.id.sw_schedule_my ->{
                swAllControl()
            }
            R.id.sw_schedule_ceremony ->{
                swAllControl()
            }
            R.id.sw_schedule_event ->{
                swAllControl()
            }
        }
    }

    private fun switchAll(boolean: Boolean){
        binding.apply {
            swScheduleAll.isChecked = boolean
            swScheduleMy.isChecked = boolean
            swScheduleCeremony.isChecked = boolean
            swScheduleEvent.isChecked = boolean
        }
    }

    private fun setPreference(){
        binding.apply {
            Preferences.scheduleMy          = if(swScheduleMy.isChecked) 1 else 0
            Preferences.scheduleCeremony    = if(swScheduleCeremony.isChecked) 1 else 0
            Preferences.scheduleEvent       = if(swScheduleEvent.isChecked) 1 else 0
        }
    }

    private fun getSetting(){
        RetrofitClient.getService().getScheduleSetting(Preferences.token).enqueue(object:
            Callback<ScheduleSetting> {
            override fun onFailure(call: Call<ScheduleSetting>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }
            override fun onResponse(call: Call<ScheduleSetting>, response: Response<ScheduleSetting>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body().apply {
                        this?.data.let {
                            items =  it as ArrayList<ScheduleSettingData>
                            Preferences.scheduleMy = items[0].my!!.toInt()
                            Preferences.scheduleCeremony = items[0].ceremony!!.toInt()
                            Preferences.scheduleEvent = items[0].event!!.toInt()
                            Log.d("data","data => ${items[0].my!!.toInt()},${items[0].ceremony!!.toInt()},${items[0].event!!.toInt()}")
                        }
                    }
                    Log.d("Preferences","${ Preferences.scheduleMy},${Preferences.scheduleCeremony},${Preferences.scheduleEvent}")
                    initView()
                }
            }

        })
    }

    private fun putSetting(){
        val my = Preferences.scheduleMy.toString()
        val ceremony = Preferences.scheduleCeremony.toString()
        val event = Preferences.scheduleEvent.toString()
        Log.d("items","items => $my : $ceremony : $event " )
        RetrofitClient.getService().putScheduleSetting(Preferences.token,my,ceremony,event).enqueue(object:
            Callback<ResponseBody> {
            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }
            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    toast("설정이 저장되었습니다.")
                    val intent = Intent(binding.root.context, MyScheduleActivity::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    startActivity(intent)
                }
            }
        })
    }



}