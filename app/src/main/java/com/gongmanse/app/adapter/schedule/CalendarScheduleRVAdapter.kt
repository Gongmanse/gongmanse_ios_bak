package com.gongmanse.app.adapter.schedule

import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.ScheduleAddActivity
import com.gongmanse.app.databinding.ItemScheduleBinding
import com.gongmanse.app.model.ScheduleDescription
import com.gongmanse.app.utils.Constants

class CalendarScheduleRVAdapter : RecyclerView.Adapter<CalendarScheduleRVAdapter.ViewHolder> () {

    private val items: ArrayList<ScheduleDescription> = ArrayList()


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {

        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_schedule,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        Log.d("item 확인","${item}")
        holder.apply {
            bind(item, View.OnClickListener {
                Log.d("클릭 이벤트","클릭")
                val intent = Intent(it.context, ScheduleAddActivity::class.java)
                if(item.type != "Personal"){
                    intent.putExtra(Constants.EXTRA_KEY_CALENDAR_TYPE, item)
                }
                intent.putExtra(Constants.EXTRA_KEY_CALENDAR_SCHEDULE, item)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                it.context.startActivity(intent)
            })
        }
    }

    fun clear(){
        items.clear()
    }

    fun detailAddItems(newItems: List<ScheduleDescription>) {
        items.clear()
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    class ViewHolder (private val binding : ItemScheduleBinding ) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : ScheduleDescription, listener: View.OnClickListener){
            binding.apply {
                itemView.setOnClickListener(listener)
                this.data = data
            }
        }
    }

}