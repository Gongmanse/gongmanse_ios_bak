package com.gongmanse.app.adapter

import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.activities.NoticeDetailWebViewActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.activities.customer.CustomerServiceDetailActivity
import com.gongmanse.app.databinding.ItemAlarmBinding
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.model.AlarmData
import com.gongmanse.app.model.EventData
import com.gongmanse.app.model.NoticeData
import com.gongmanse.app.model.OneToOneData
import com.gongmanse.app.utils.Constants
import org.json.JSONObject

class AlarmRVAdapter: RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        private val TAG = AlarmRVAdapter::class.java.simpleName
    }

    private val items: ObservableArrayList<AlarmData> = ObservableArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemAlarmBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ItemViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int) = position.toLong()

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ItemViewHolder) {
            populateItemRows(holder, position)
        } else if (holder is LoadingViewHolder) {
            showLoadingView(holder, position)
        }
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {

    }

    private fun populateItemRows(holder: ItemViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            itemView.tag = item
            bind(item) {
                val json =  item.sData?.let { JSONObject(it) }
                if (json?.isNull("deepLink") == true) { // 값이 없음
                    Toast.makeText(this.itemView.context, "내용이 없습니다.", Toast.LENGTH_SHORT).show()
                } else {
                    Constants.payloadLink(this.itemView.context, json?.get("deepLink") as String?)
                }
            }
        }
    }

    fun addItems(newItems: List<AlarmData>) {
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun addLoading() {
        val item = AlarmData().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
        items.add(item)
        notifyItemInserted(items.size - 1)
    }

    fun removeLoading() {
        val position = items.size - 1
        if (items[position].itemType == Constants.VIEW_TYPE_LOADING) {
            items.removeAt(position)
            val scrollPosition = items.size
            notifyItemRemoved(scrollPosition)
        }
    }

    private class ItemViewHolder (private val binding : ItemAlarmBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data: AlarmData, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                this.root.setOnClickListener(listener)
            }
        }
    }

    private class LoadingViewHolder (private val binding : ItemLoadingBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(){
            binding.apply {

            }
        }
    }

}