package com.gongmanse.app.adapter.progress

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemProgressUnitBinding
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import com.gongmanse.app.model.ProgressData
import kotlinx.android.synthetic.main.item_progress_unit.view.*

class ProgressUnitRVAdapter(private val listener: OnBottomSheetProgressListener) : RecyclerView.Adapter<ProgressUnitRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = ProgressUnitRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<ProgressData> = ArrayList()
    private var positions:Int = 0


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_progress_unit,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item, View.OnClickListener{
                listener.onSelectionUnit("selectionUnit", item.id?.toInt(), item.jindoTitle.toString())
                Log.e(TAG, "id: ${item.id}, jindoTitle:${item.jindoTitle}")
            })
        }
    }

    fun getPosition(selectText: String?): Int {
        Log.e(TAG, "selectText => $selectText")
        return if (items.isEmpty()) {
            positions = 0
            positions
        } else {
            Log.e(TAG, "items => $items")
            positions = items.withIndex().filter { it.value.jindoTitle == selectText }.map { it.index }.first()
            positions
        }
    }

    fun setCurrent(currentPosition: Int) {
        Log.e(TAG,"position => $currentPosition")
        items[currentPosition].isCurrent = true
    }

    fun addItems(newItems: List<ProgressData>) {
        Log.e(TAG, "newItems => $newItems")
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    inner class ViewHolder(private val binding: ItemProgressUnitBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(
            data: ProgressData,
            listener: View.OnClickListener
        ) {
            binding.apply {
                this.title = data
                layoutUnit.setOnClickListener(listener)
            }

        }
    }
}