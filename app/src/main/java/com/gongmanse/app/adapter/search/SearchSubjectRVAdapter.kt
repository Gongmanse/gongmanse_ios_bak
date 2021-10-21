package com.gongmanse.app.adapter.search

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.adapter.progress.ProgressGradeCurrentRVAdapter
import com.gongmanse.app.databinding.ItemSubjectBinding
import com.gongmanse.app.listeners.OnBottomSheetSubjectListener
import com.gongmanse.app.model.SearchSubjectListData

class SearchSubjectRVAdapter(private val listener: OnBottomSheetSubjectListener) : RecyclerView.Adapter<SearchSubjectRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = SearchSubjectRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<SearchSubjectListData> = ArrayList()
    private var positions:Int = 0


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_subject,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item, View.OnClickListener {
                if (item.id != null) listener.onSelectionSubject(item.id, item.subject)
                else listener.onSelectionSubject(38, item.subject)
                Log.d(TAG, "Id: ${item.id}, subject: ${item.subject}")
            })
        }
    }

    inner class ViewHolder(private val binding: ItemSubjectBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind( data: SearchSubjectListData, listener: View.OnClickListener ) {
            binding.apply {
                this.search = data
                layoutSubject.setOnClickListener(listener)
            }
        }

    }

    fun addItems(newItems: List<SearchSubjectListData>) {
        Log.e(TAG, "newItems => $newItems")
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun getPosition(selectText: String?): Int {
        Log.e(TAG,"selectText => $selectText")
        return if (items.isEmpty()) {
            positions = 0
            positions
        } else {
            positions = items.withIndex().filter { it.value.subject == selectText }.map { it.index }.first()
            positions
        }
    }

    fun setCurrent(currentPosition: Int) {
        Log.d(TAG,"position => $currentPosition")
        items[currentPosition].isCurrent = true
    }
}