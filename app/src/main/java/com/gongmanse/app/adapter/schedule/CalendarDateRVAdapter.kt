package com.gongmanse.app.adapter.schedule

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemDateBinding
import com.gongmanse.app.listeners.OnScheduleClickListener
import com.gongmanse.app.model.ScheduleData
import kotlinx.android.synthetic.main.item_date.view.*
import kotlin.properties.Delegates

class CalendarDateRVAdapter( private val listener: OnScheduleClickListener) : RecyclerView.Adapter<CalendarDateRVAdapter.ViewHolder> () {

    private val items: ArrayList<ScheduleData> = ArrayList()
    private lateinit var currentViewHolder: ViewHolder
    private var calYear by Delegates.notNull<Int>()
    private var calMonth by Delegates.notNull<Int>()
    private var nowMonth by Delegates.notNull<Int>()
    private var nowDate by Delegates.notNull<Int>()



    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {

        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_date,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int = items.size

    private var nowViewHolder: ViewHolder? = null
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            val date = 0
            if(item.date != ""){
                item.date!!.substring(7).toInt()
            }
            bind(item, View.OnClickListener {
                if (item.date != "") {
                    if (::currentViewHolder.isInitialized) {
                        currentViewHolder.itemView.tv_title.setBackgroundResource(R.color.white)
                        currentViewHolder.itemView.tv_title.setTextColor(ContextCompat.getColor(it.context,R.color.date_color_num))
                    }
                    currentViewHolder = this
                    if (calMonth == nowMonth && date == nowDate) {
                        nowViewHolder = this
                        currentViewHolder.itemView.tv_title.setBackgroundResource(R.drawable.background_round_main_color)
                        currentViewHolder.itemView.tv_title.setTextColor(ContextCompat.getColor(it.context,R.color.white))
                    } else {
                        currentViewHolder.itemView.tv_title.setBackgroundResource(R.drawable.background_round_click_color)
                        currentViewHolder.itemView.tv_title.setTextColor(ContextCompat.getColor(it.context,R.color.white))
                        nowViewHolder?.apply {
                            itemView.tv_title.setBackgroundResource(R.drawable.background_round_main_color)
                            itemView.tv_title.setTextColor(ContextCompat.getColor(it.context,R.color.white))
                            nowViewHolder = null
                        }
                    }
                    Log.d("클릭 년도", "$calYear")
                    Log.d("클릭 날짜", "${calMonth}월 ${item}일")
                    Log.d("오늘 날짜", "${nowMonth}월 ${nowDate}일")
                    Log.d("클릭 날짜", "${item.date}")

                    listener.dateClick(item.description,item.date)
                }
            })
        }
    }

    fun addItems(newItems : ArrayList<ScheduleData>){
        items.clear()
        newItems.sortBy { it.date }
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun checkYear(calYear : Int){
        this.calYear = calYear
    }

    fun checkMonth(calMonth : Int , nowMonth : Int){
        this.calMonth = calMonth
        this.nowMonth = nowMonth
    }
    fun checkDate(date : Int){
        this.nowDate = date
    }

    class ViewHolder (private val binding : ItemDateBinding ) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : ScheduleData,listener: View.OnClickListener){
            binding.apply {
                itemView.setOnClickListener(listener)
                this.data = data
            }
        }
    }


}