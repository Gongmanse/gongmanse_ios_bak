package com.gongmanse.app.activities

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.text.Editable
import android.text.Html
import android.text.Spanned
import android.text.TextWatcher
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.FragmentActivity
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityScheduleAddBinding
import com.gongmanse.app.fragments.sheet.*
import com.gongmanse.app.listeners.*
import com.gongmanse.app.model.Schedule
import com.gongmanse.app.model.ScheduleDescription
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import kotlinx.android.synthetic.main.dialog_sheet_selection_of_alarm.view.*
import okhttp3.ResponseBody
import org.jetbrains.anko.alert
import org.jetbrains.anko.noButton
import org.jetbrains.anko.toast
import org.jetbrains.anko.yesButton
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.text.SimpleDateFormat
import java.util.*

@SuppressLint("SetTextI18n")
class ScheduleAddActivity : AppCompatActivity() ,View.OnClickListener,
    OnBottomSheetSelectDateListener, OnBottomSheetSelectTimeListener, OnBottomSheetAlarmRepeatListener,
    OnBottomSheetAlarmRepeatDayListener,OnBottomSheetAlarmRepeatYearListener,OnBottomSheetAlarmRepeatMonthListener {

    private lateinit var bottomSheetDate: SelectionSheetDate
    private lateinit var bottomSheetTime: SelectionSheetTime
    private lateinit var bottomSheetAlarm: SelectionSheetAlarm
    private lateinit var bottomSheetRepeat: SelectionSheetRepeat
    private lateinit var bottomSheetRepeatDayDayCounter : SelectionSheetRepeatDayCounter
    private lateinit var bottomSheetRepeatYearCounter : SelectionSheetRepeatYearCounter
    private lateinit var bottomSheetRepeatMonthCounter : SelectionSheetRepeatMothCounter


    private var endTemp : String? = null
    private var startTemp : String? = null
    private var selectedDate: String? = null
    private var selectedTime : String? = null
    private var selectedAlarm : String? = null
    private var selectedRepeat : String? = null
    private var dayOfWeek : String =""
    private var weekOfMonth : String =""
    private var dayOfMonth : String = ""
    private var monthOfYear : String = ""
    private val reqAlarmArray = arrayListOf<String>()
    private val resAlarmArray = arrayListOf<String>()
    private var wholeDayStart = ""
    private var wholeDayEnd = ""
    private var fromType = true
    private var clickAble = true

    //업로드용 변수
    private var calendarId : String? = null
    private var title : String? = null
    private var content : String? = null
    private var isWholeDay : String? = null
    private var startDate : String? = null
    private var endDate : String? = null
    private var alarm : String? = null
    private var repeat : String? = null
    private var repeatCount : String? = null
    private var repeatRadio : String? = null

    companion object {
        private val TAG = MyScheduleActivity::class.java.simpleName
    }

    private lateinit var binding : ActivityScheduleAddBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = DataBindingUtil.setContentView(this,R.layout.activity_schedule_add)
        binding.setVariable(BR.tool, Constants.ACTIONBAR_TITLE_SCHEDULE_REG)
        binding.btnRemove.visibility = View.GONE
        binding.layoutButton.btnText = Constants.BUTTON_TEXT_REG

        initData()
        initView()
    }

    private fun initData(){
        getData()
    }

    private fun initView(){
        getTimes()
        titleCheck()
        Log.d("fromType","$fromType")
        binding.apply {
            if(!fromType) {
                layoutButton.btnText = Constants.CONTENT_VALUE_BUTTON_TEXT
            }
            layoutButton.cvBtn.setOnClickListener {
                if(etTitle.text.isNullOrEmpty()){
                    toast("제목을 입력해 주세요")
                }else{
                    timeCheck()
                }

            }
        }
    }
    private fun getTimes(){
        startTemp = binding.tvStartSelect.text.toString()
        endTemp = binding.tvEndSelect.text.toString()
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.btn_close -> onBackPressed()
            R.id.layout_start_select ->{
                startDate = binding.tvStartSelect.text.toString()
                if(startDate == Constants.VALUE_WHOLE_DAY && binding.swAllDay.isChecked){
                    startDate = startTemp!!
                    endDate = endTemp!!
                    binding.swAllDay.isChecked = false
                    switchClick()
                }
                if(!startDate.isNullOrEmpty()) bottomSheetDate = SelectionSheetDate(this,startDate!!,Constants.START_TIME)
                showDatePicker()
            }
            R.id.layout_end_select ->{
                endDate = binding.tvEndSelect.text.toString()
                if(endDate == Constants.VALUE_WHOLE_DAY && binding.swAllDay.isChecked){
                    startDate = startTemp!!
                    endDate = endTemp!!
                    binding.swAllDay.isChecked = false
                    switchClick()
                }
                if(!endDate.isNullOrEmpty()) bottomSheetDate = SelectionSheetDate(this,endDate!!,Constants.END_TIME)
                showDatePicker()
            }
            R.id.tv_alarm_select ->{
                selectedAlarm = binding.tvAlarmSelect.text.toString()
                bottomSheetAlarm = SelectionSheetAlarm(this,selectedAlarm!!)
                Log.d("알림선택","$selectedAlarm")
                showAlarmPicker()
            }
            R.id.tv_repeat_select ->{
                if(!binding.swAllDay.isChecked){
                    selectedRepeat = binding.tvRepeatSelect.text.toString()
                    bottomSheetRepeat = SelectionSheetRepeat(this,selectedRepeat!!)
                    Log.d("반복선택","$selectedRepeat")
                    showRepeatPicker()
                }else{
                    toast("하루종일 선택시 반복설정 할 수 없습니다.")
                }
            }
            R.id.sw_all_day ->{
                switchClick()
            }
            R.id.btn_remove ->{
               deleteAlert()
            }
        }
    }
    @Suppress("DEPRECATION")
    private fun String.htmlToString(): Spanned {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Html.fromHtml(this, Html.FROM_HTML_MODE_LEGACY)
        } else {
            Html.fromHtml(this)
        }
    }

    private fun deleteAlert(){
        alert(message = "삭제 하시겠습니까?") {
            yesButton { deleteSchedule() }
            noButton { it.dismiss() }
        }.show()
    }

    private fun getData(){
        if(intent.hasExtra(Constants.EXTRA_KEY_CALENDAR_NOW_DATE)){
            binding.date = intent.getStringExtra(Constants.EXTRA_KEY_CALENDAR_NOW_DATE)
        }else{
            binding.date = intent.getStringExtra(Constants.EXTRA_KEY_CALENDAR_CLICK_DATE)
        }

        //목록 클릭 후 수정 페이지 세팅
        if(intent.hasExtra(Constants.EXTRA_KEY_CALENDAR_SCHEDULE)){
            (intent.getSerializableExtra(Constants.EXTRA_KEY_CALENDAR_SCHEDULE) as ScheduleDescription).let {
                binding.apply {
                    fromType = false
                    this.etTitle.setText(it.title?.htmlToString())
                    this.etContent.setText(it.content?.htmlToString())
                    this.tvStartSelect.text = it.startDate
                    this.tvEndSelect.text = it.endDate
                    this.tvAlarmSelect.text = it.alarmCode ?: "없음"
                    this.tvRepeatSelect.text = it.repeatCode ?: "없음"
                    calendarId = it.calendarId
                    title = it.title
                    content = it.content
                    isWholeDay = it.wholeDay
                    startDate = it.startDate
                    endDate = it.endDate
                    alarm = it.alarmCode
                    repeat = it.repeatCode
                    repeatCount = it.repeatCount
                    repeatRadio = it.repeatRadio
                }
            }
        }
        if(intent.hasExtra(Constants.EXTRA_KEY_CALENDAR_TYPE)){
            binding.apply {
                clickDefense(false)
            }
        }
        getStringArray()
        statusView()
    }

    private fun statusView(){
        if(clickAble && !fromType){
            binding.setVariable(BR.tool, Constants.ACTIONBAR_TITLE_SCHEDULE_MOD)
            binding.btnRemove.visibility = View.VISIBLE
            binding.layoutButton.cvBtn.setCardBackgroundColor(ContextCompat.getColorStateList(binding.root.context, R.color.main_color))
        }

    }
    private fun clickDefense(bool : Boolean){
        clickAble = bool
        binding.apply {
            etTitle.isEnabled = clickAble
            etContent.isEnabled = clickAble
            layoutStartSelect.isEnabled = clickAble
            layoutEndSelect.isEnabled = clickAble
            tvAlarmSelect.isEnabled = clickAble
            tvRepeatSelect.isEnabled = clickAble
            swAllDay.isEnabled = clickAble
            layoutButton.cvBtn.isEnabled = clickAble
        }
    }

    private fun showDatePicker(){
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetDate.show(supportManager, bottomSheetDate.tag)
    }
    private fun showTimePicker(){
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetTime.show(supportManager, bottomSheetTime.tag)
    }
    private fun showAlarmPicker(){
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetAlarm.show(supportManager, bottomSheetAlarm.tag)
    }
    private fun showRepeatPicker(){
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetRepeat.show(supportManager, bottomSheetRepeat.tag)
    }
    private fun showRepeatDayNumberPicker(){
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetRepeatDayDayCounter.show(supportManager, bottomSheetRepeatDayDayCounter.tag)
    }
    private fun showRepeatMonthPicker(){
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetRepeatMonthCounter.show(supportManager, bottomSheetRepeatMonthCounter.tag)
    }
    private fun showRepeatYearPicker(){
        val supportManager = (binding.root.context as FragmentActivity).supportFragmentManager
        bottomSheetRepeatYearCounter.show(supportManager, bottomSheetRepeatYearCounter.tag)
    }

    // 하루종일 클릭
    private fun switchClick(){
        Log.d("switchClick","스위치진입")
        binding.apply {
            if(swAllDay.isChecked){
                Log.d("switchClick","스위치진입 => ${swAllDay.isChecked}")
                startTemp = binding.tvStartSelect.text.toString()
                endTemp = binding.tvStartSelect.text.toString()
                binding.tvStartSelect.text = Constants.VALUE_WHOLE_DAY
                binding.tvEndSelect.text = Constants.VALUE_WHOLE_DAY
                isWholeDay = "1"
                val startTime = startTemp!!.substring(0,10)
                wholeDayStart ="$startTime 00:00"
                wholeDayEnd = "$startTime 23:59"
                startDate = wholeDayStart
                endDate = wholeDayEnd
                repeatCount = null
                repeat = null
                repeatRadio = null
                tvRepeatSelect.text = Constants.CONTENT_VALUE_REPEAT_NULL
                //시작 종료 입력, 시작종료 화면변경
            }else{
                Log.d("switchClick","스위치진입 => ${swAllDay.isChecked}")
                binding.tvStartSelect.text = startTemp
                binding.tvEndSelect.text = endTemp
                isWholeDay = null
                startDate = startTemp
                endDate = endTemp
            }
        }

    }

    //날짜 선택했을 때 adapter 에서 반환된것
    override fun selectionDate(date: String,type : Int) {
        Log.d("selectionDate", date)
        bottomSheetTime = SelectionSheetTime(this, type ,date)
        selectedDate = date
        showTimePicker()
    }

    private fun getStringArray(){
        val arr =  resources.getStringArray(R.array.alarm)
        val arr2 = resources.getStringArray(R.array.alarm2)
        for(i in arr){
            reqAlarmArray.add(i)
        }
        for(i in arr2){
            resAlarmArray.add(i)
        }
    }
    // 선택된 글자에 따라서 값 할당
    private fun getTitleAndContent(){
        binding.apply {
            title = etTitle.text.toString()
            Log.d("타이틀","$title : ${etTitle.text}")
            content = etContent.text.toString()
            alarm = when(tvAlarmSelect.text.toString()){
                reqAlarmArray[0] -> null
                reqAlarmArray[1] -> resAlarmArray[0]
                reqAlarmArray[2] -> resAlarmArray[1]
                reqAlarmArray[3] -> resAlarmArray[2]
                reqAlarmArray[4] -> resAlarmArray[3]
                reqAlarmArray[5] -> resAlarmArray[4]
                reqAlarmArray[6] -> resAlarmArray[5]
                reqAlarmArray[7] -> resAlarmArray[6]
                reqAlarmArray[8] -> resAlarmArray[7]
                else -> null
            }
            if(!swAllDay.isChecked){
                startDate = binding.tvStartSelect.text.toString()
                endDate = binding.tvEndSelect.text.toString()
            }
        }
    }
    private fun uploadSchedule(){
        getTitleAndContent()
        RetrofitClient.getService().uploadCalendar(
            Preferences.token,title,content,isWholeDay,startDate,endDate,alarm,repeat,repeatCount,repeatRadio
        ).enqueue(object:
            Callback<ResponseBody> {
            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                Log.d("실패", "call : $title / $content / $isWholeDay / $startDate / $endDate / $alarm / $repeat / $repeatCount / $repeatRadio /")
            }

            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                if (!response.isSuccessful){
                    Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                    Log.d("Failed", " $title / $content / $isWholeDay / $startDate / $endDate / $alarm / $repeat / $repeatCount / $repeatRadio /")
                }
                if (response.isSuccessful) {
                    toast("업로드 완료")
                    Log.d("성공", "call : $title / $content / $isWholeDay / $startDate / $endDate / $alarm / $repeat / $repeatCount / $repeatRadio /")
                    val intent = Intent(binding.root.context, MyScheduleActivity::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    startActivity(intent)
                    finish()
                }
            }
        })
    }
    private fun uploadSchedule(calendarId : String){
        getTitleAndContent()
        RetrofitClient.getService().uploadCalendar(calendarId,
            Preferences.token,title,content,isWholeDay,startDate,endDate,alarm,repeat,repeatCount,repeatRadio
        ).enqueue(object:
            Callback<ResponseBody> {
            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                Log.d("실패", "call : $title / $content / $isWholeDay / $startDate / $endDate / $alarm / $repeat / $repeatCount / $repeatRadio /")
            }

            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                if (!response.isSuccessful){
                    Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                    Log.d("Failed", " $title / $content / $isWholeDay / $startDate / $endDate / $alarm / $repeat / $repeatCount / $repeatRadio /")
                }
                if (response.isSuccessful) {
                    toast("업로드 완료")
                    Log.d("성공", "call : $title / $content / $isWholeDay / $startDate / $endDate / $alarm / $repeat / $repeatCount / $repeatRadio /")
                    val intent = Intent(binding.root.context, MyScheduleActivity::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    startActivity(intent)
                    finish()
                }
            }
        })
    }

    private fun deleteSchedule(){
        calendarId?.let {
            RetrofitClient.getService().deleteCalendar(
                it
            ).enqueue(object:
                Callback<ResponseBody> {
                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                    Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                    Log.d("실패", "call : $title / $content / $isWholeDay / $startDate / $endDate / $alarm / $repeat / $repeatCount / $repeatRadio /")
                }

                override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                    if (!response.isSuccessful){
                        Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                        Log.d("Failed", " $title / $content / $isWholeDay / $startDate / $endDate / $alarm / $repeat / $repeatCount / $repeatRadio /")
                    }
                    if (response.isSuccessful) {
                        toast("삭제 되었습니다.")
                        val intent = Intent(binding.root.context, MyScheduleActivity::class.java)
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        startActivity(intent)
                        finish()
                    }
                }
            })
        }

    }

    override fun selectionTime(date: String, type : Int) {
        Log.d("selectionTime", date)
        selectedTime = date
        if(type == Constants.START_TIME){
            setStart()
        }else{
            setEnd()
        }
    }

    override fun selectionBack(date : String,type: Int) {
        bottomSheetDate = SelectionSheetDate(this,date,type)
        showDatePicker()
    }

    private fun setStart(){
        binding.tvStartSelect.text = "$selectedDate $selectedTime"
        startDate = "$selectedDate $selectedTime"
    }
    private fun setEnd(){
        binding.tvEndSelect.text = "$selectedDate $selectedTime"
        endDate = "$selectedDate $selectedTime"
    }

    @SuppressLint("SimpleDateFormat")
    private fun timeCheck(){
        var startDateText =  binding.tvStartSelect.text.toString()
        var endDateText = binding.tvEndSelect.text.toString()
        if(startDateText == "하루종일"){
            Log.d("하루종일", "$startDateText : $wholeDayStart" )
            startDateText = wholeDayStart
            endDateText = wholeDayEnd
        }
        val simpleDateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm")
        val start = simpleDateFormat.parse(startDateText)
        val end =simpleDateFormat.parse(endDateText)
        Log.d("timeCheck","$start : $end")
        if(start!!.time >= end!!.time){
            toast("종료 시간이 시작 시간과 같거나 이전일 수 없습니다.")
        }else{
            if(fromType){
                uploadSchedule()
            }else{
                calendarId?.let { uploadSchedule(it) }
            }
        }


    }
    private fun titleCheck(){
        binding.etTitle.addTextChangedListener(object : TextWatcher{
            override fun afterTextChanged(s: Editable?) {
                if(s.isNullOrEmpty()){
                    binding.layoutButton.cvBtn.setCardBackgroundColor(ContextCompat.getColorStateList(binding.root.context, R.color.gray))
                }else{
                    binding.layoutButton.cvBtn.setCardBackgroundColor(ContextCompat.getColorStateList(binding.root.context, R.color.main_color))
                }
            }
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
        })
    }
    private fun parserDate(selectedStartDate: String){
        val calendar = Calendar.getInstance()

        val format = SimpleDateFormat("yyyy-MM-dd", Locale.KOREA)

        val date = format.parse(selectedStartDate)
        date?.let {
            val transDate = format.format(date)
            val dates = transDate.split("-")
            val year  =  Integer.parseInt(dates[0])
            val month =  Integer.parseInt(dates[1])
            val day   =  Integer.parseInt(dates[2])
            dayOfMonth = day.toString()
            monthOfYear = month.toString()
            calendar.set(year,month-1,day)
            weekOfMonth =calendar.get(Calendar.WEEK_OF_MONTH).toString() // 이달의 몇 주차
            when(calendar.get(Calendar.DAY_OF_WEEK)){
                1 -> dayOfWeek = "일"
                2 -> dayOfWeek = "월"
                3 -> dayOfWeek = "화"
                4 -> dayOfWeek = "수"
                5 -> dayOfWeek = "목"
                6 -> dayOfWeek = "금"
                7 -> dayOfWeek = "토"
            }
            Log.d("weekOfMonth" , "$weekOfMonth : $dayOfWeek : $day")
        }
    }

    override fun selectionAlarm(value: String) {
        selectedAlarm = value
        binding.tvAlarmSelect.text = selectedAlarm
    }

    override fun selectionRepeat(value: String) {
        val startSelectText = binding.tvStartSelect.text.toString()

        selectedRepeat = value
        when(value){
            Constants.CONTENT_VALUE_REPEAT_DAY      -> {
                bottomSheetRepeatDayDayCounter = SelectionSheetRepeatDayCounter(this,value)
                showRepeatDayNumberPicker()
            }  //숫자선택 바텀시트
            Constants.CONTENT_VALUE_REPEAT_MONTH    -> {
                parserDate(startSelectText)
                bottomSheetRepeatMonthCounter = SelectionSheetRepeatMothCounter(this,weekOfMonth,dayOfWeek,dayOfMonth)
                showRepeatMonthPicker()
            }
            Constants.CONTENT_VALUE_REPEAT_YEAR     -> {
                parserDate(startSelectText)
                bottomSheetRepeatYearCounter = SelectionSheetRepeatYearCounter(this,weekOfMonth,dayOfWeek,dayOfMonth,monthOfYear)
                showRepeatYearPicker()
            }
            else -> {
                binding.tvRepeatSelect.text = selectedRepeat
                repeat = "weekly"
            }
        }

    }
    // 반복 -> 매일 선택후 뒤로가기 클릭시
    override fun selectionRepeatBack(value: String) {
        bottomSheetRepeat = SelectionSheetRepeat(this, value)
        showRepeatPicker()
    }
    // 반복 -> 매일 선택후 완료 클릭시
    override fun selectionRepeatDay(selected : String, value: String) {
        binding.tvRepeatSelect.text = "$selected $value 일마다"
        repeatCount = value
        repeat = "daily"
    }

    override fun selectionRepeatMonth(index: Int,value: String) {
        when(index){
            Constants.DAY_OF_MONTH -> repeatRadio = "D"
            Constants.WEEK_OF_MONTH-> repeatRadio = "D_wom_dow"
        }
        binding.tvRepeatSelect.text = value
        repeat = "monthly"
        Log.d("repeat_radio","$repeatRadio")
    }

    override fun selectionRepeatYear(index: Int , value: String) {
        when(index){
            Constants.MONTH_DAY -> repeatRadio = "M_D"
            Constants.MONTH_WEEK_OF_DAY-> repeatRadio = "M_D_wom_dow"
        }
        binding.tvRepeatSelect.text = value
        repeat = "yearly"
        Log.d("repeat_radio","$repeatRadio")
    }
}