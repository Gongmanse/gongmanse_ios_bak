package com.gongmanse.app.adapter.notice

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.NoticeDetailWebViewActivity
import com.gongmanse.app.adapter.bindViewImgTag
import com.gongmanse.app.databinding.ItemNoticeEventBinding
import com.gongmanse.app.model.EventData
import org.jetbrains.anko.intentFor
import java.util.regex.Matcher
import java.util.regex.Pattern

class EventRVAdapter : RecyclerView.Adapter<EventRVAdapter.ViewHolder>(){

    companion object {
        private val TAG = EventRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<EventData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_notice_event, parent, false
            )
        )
    }

    fun addItems(newItems: List<EventData>) {
        Log.e(TAG, "newItems => $newItems")
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        Log.d(TAG, "onBindViewHolder")
        val item = items[position]
        holder.apply {
            bind(item) {
                itemView.context.apply { startActivity(intentFor<NoticeDetailWebViewActivity>("event" to item)) }
            }
        }
    }

    inner class ViewHolder(private val binding: ItemNoticeEventBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: EventData, listener: View.OnClickListener) {
            binding.apply {
                this.event = data
                this.layoutRoot.setOnClickListener(listener)
            }
        }


    }

}