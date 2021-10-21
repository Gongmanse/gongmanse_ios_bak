package com.gongmanse.app.fragments.schedule

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.*
import android.view.animation.TranslateAnimation
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import com.gongmanse.app.R
import com.gongmanse.app.activities.MyScheduleActivity
import com.gongmanse.app.activities.ScheduleAddActivity
import com.gongmanse.app.adapter.schedule.CalendarDateRVAdapter
import com.gongmanse.app.adapter.schedule.CalendarScheduleRVAdapter
import com.gongmanse.app.adapter.schedule.CalendarWeekRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentMyScheduleCalendarBinding
import com.gongmanse.app.listeners.OnScheduleClickListener
import com.gongmanse.app.model.*
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.support.v4.intentFor
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList
import kotlin.properties.Delegates


class MyScheduleCalendarFragment : Fragment() , OnScheduleClickListener {

    companion object {
        private val TAG = MyScheduleCalendarFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentMyScheduleCalendarBinding
    private lateinit var mActivity : Activity
    private lateinit var mRecyclerAdapterDate : CalendarDateRVAdapter
    private val mRecyclerAdapterWeek by lazy { CalendarWeekRVAdapter() }
    private val mRecyclerAdapterSchedule by lazy { CalendarScheduleRVAdapter() }
    private var page = -1
    private lateinit var mCal : Calendar
    private var dataItems: ArrayList<ScheduleData> = ArrayList()
    private var dayNum = 0
    private var clickDate : String? = null
    private var nowDate : String? = null


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater,R.layout.fragment_my_schedule_calendar, container, false)

        intiData()
        initView()

        return binding.root
    }

    private fun initView() {
        mRecyclerAdapterDate = CalendarDateRVAdapter(this)
        setRVLayout()
        setCalendar(page)
        binding.ivPrevious.setOnClickListener {
            page -= 1
            setCalendar(page)
        }
        binding.ivNext.setOnClickListener {
            page += 1
            setCalendar(page)
        }
        binding.btnAddSchedule.setOnClickListener {
            if(clickDate == null){
                startActivity(intentFor<ScheduleAddActivity>(
                    Constants.EXTRA_KEY_CALENDAR_NOW_DATE to nowDate
                ).singleTop())
            }else{
                startActivity(intentFor<ScheduleAddActivity>(
                    Constants.EXTRA_KEY_CALENDAR_CLICK_DATE to clickDate
                ).singleTop())
            }
        }
        binding.layoutRoot.setOnClickListener {
            bottomHide()
        }
    }
    fun bottomShow(){
        binding.layoutBottom.visibility = View.GONE
        val animation = TranslateAnimation(0f,0f,0f,0f)
        animation.duration = 400
        binding.layoutBottom.animation = animation
        binding.layoutBottom.visibility = View.VISIBLE
    }
    private fun intiData() {
        mActivity = MyScheduleActivity()
    }
    fun bottomHide(){
        binding.layoutBottom.visibility = View.GONE
    }


    private fun setRVLayout() {
        binding.rvDate.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            val linearLayout = GridLayoutManager(context,7)
            layoutManager = linearLayout
        }
        binding.rvWeek.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            val linearLayout = GridLayoutManager(context,7)
            layoutManager = linearLayout
        }
        binding.rvSchedule.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            val linearLayout = LinearLayoutManager(context)
            layoutManager = linearLayout
        }
        if (binding.rvDate.adapter == null) {
            binding.rvDate.adapter = mRecyclerAdapterDate
        }
        if (binding.rvWeek.adapter == null) {
            binding.rvWeek.adapter = mRecyclerAdapterWeek
        }
        if (binding.rvSchedule.adapter == null) {
            binding.rvSchedule.adapter = mRecyclerAdapterSchedule
        }
    }
    @SuppressLint("SetTextI18n")
    private fun setCalendar(page : Int){
        val now : Long = System.currentTimeMillis()
        val date = Date(now)

        val curYearFormat = SimpleDateFormat("yyyy", Locale.KOREA)
        val curMonthFormat = SimpleDateFormat("MM", Locale.KOREA)
        val curDayFormat = SimpleDateFormat("dd", Locale.KOREA)

        val dayList = ArrayList<String>()
        val weekArray =resources.getStringArray(R.array.week)
        val weekList : ArrayList<String> = arrayListOf()
        for(i in weekArray){
            weekList.add(i)
        }


        mCal = Calendar.getInstance()
        mCal.set(Integer.parseInt(curYearFormat.format(date)), Integer.parseInt(curMonthFormat.format(date))+page, 1)
        Log.d("YEAR", "${mCal.get(Calendar.YEAR)}")
        Log.d("MONTH", "${mCal.get(Calendar.MONTH)+1}")
        Log.d("DATE", "${mCal.get(Calendar.DATE)}")
        val calYear = mCal.get(Calendar.YEAR)
        val month = mCal.get(Calendar.MONTH)+1
        val year = Integer.parseInt(curYearFormat.format(date))
        dayNum = mCal.get(Calendar.DAY_OF_WEEK)




        val searchDate = "$calYear-${String.format("%02d",month)}"
        Log.d("searchDate check", "searchDate => $searchDate")

        loadSchedule(searchDate)

        for(i in 1 .. mCal.getActualMaximum(Calendar.DAY_OF_MONTH)){
            dayList.add(i.toString())
        }
        binding.tvCalendarTitle.text= "${calYear}년 ${month}월"

        nowDate ="$year-${curMonthFormat.format(date)}-${curDayFormat.format(date)}"

        mRecyclerAdapterDate.checkYear(year)
        mRecyclerAdapterDate.checkMonth(month,Integer.parseInt(curMonthFormat.format(date)))
        mRecyclerAdapterDate.checkDate(Integer.parseInt(curDayFormat.format(date)))

        mRecyclerAdapterWeek.addItems(weekList)


    }

    override fun dateClick(data : List<ScheduleDescription>?, date:String?) {
        if (date != null) {
            clickDate = date
        }
        data?.let{
            if(it.isEmpty()){
                binding.layoutEmpty.root.visibility = View.VISIBLE
                binding.rvSchedule.visibility = View.GONE
                binding.layoutEmpty.tvInfo.text = Constants.CONTENT_VALUE_EMPTY_SCHEDULE
            }else{
                binding.layoutEmpty.root.visibility = View.GONE
                binding.rvSchedule.visibility = View.VISIBLE
                mRecyclerAdapterSchedule.detailAddItems(it)
            }
            bottomShow()
        }
    }

    private fun loadSchedule(value : String){
        RetrofitClient.getService().getMyScheduleList(Preferences.token, value).enqueue(object: Callback<Schedule> {
            override fun onFailure(call: Call<Schedule>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Schedule>, response: Response<Schedule>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {
                        for(i in 1 until dayNum){
                            dataItems.add(
                                ScheduleData("",null)
                            )
                        }
                        Log.d("response","response : ${ response.body()}")
                        data?.apply {
                            dataItems.addAll(this)
                            mRecyclerAdapterDate.addItems(dataItems)
                            dataItems.clear()
                            Log.d("아이템 정상화 테스트","${dataItems}")
                        }
                    }
                }
            }
        })
    }


//    private fun dateCalculation(){
//        items.apply{
//            for(i in 0 until this.size){
//                this[i].date?.let { mRecyclerAdapterDate.addScheduleList(it) }
//            }
//        }
//    }
}