package com.gongmanse.app.adapter.active

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.CompoundButton
import android.widget.Toast
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemSheetQnaBinding
import com.gongmanse.app.model.QNADetailData
import com.gongmanse.app.utils.Constants

class QNADetailRVAdapter : RecyclerView.Adapter<QNADetailRVAdapter.ViewHolder> () {

    companion object {
        private val TAG = QNADetailRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<QNADetailData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_sheet_qna,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int) = position.toLong()

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item, CompoundButton.OnCheckedChangeListener { _, isChecked ->
                items[position].isRemove = isChecked
            })
            itemView.tag = item
        }
    }

    fun addItems(newItems: List<QNADetailData>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun setAllChecked() {
        val list = arrayListOf<QNADetailData>()
        items.forEach {
            it.isRemove = true
            list.add(it)
        }
        items.clear()
        items.addAll(list)
        notifyDataSetChanged()
    }

    fun removeItems(): ArrayList<String> {
        val list = arrayListOf<String>()
        items.filter { it.isRemove }
            .forEach {
                it.id?.let { it1 ->
                    if(it.answer.isNullOrEmpty()){
                        list.add(it1)
                    }
                }
            }
        return list
    }

    fun removeItemsSize(): Int {
        return items.filter { it.isRemove }.size
    }

    fun addLoading() {
        val item = QNADetailData().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
        items.add(item)
        notifyItemInserted(items.size -1)
    }

    fun removeLoading() {
        val position = items.size -1
        if (items[position].itemType == Constants.VIEW_TYPE_LOADING) {
            items.removeAt(position)
            val scrollPosition = items.size
            notifyItemRemoved(scrollPosition)
        }
    }

    class ViewHolder (private val binding : ItemSheetQnaBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : QNADetailData, listener: CompoundButton.OnCheckedChangeListener){
            binding.apply {
                this.data = data
                cbItem.setOnCheckedChangeListener(listener)
            }
        }
    }

}