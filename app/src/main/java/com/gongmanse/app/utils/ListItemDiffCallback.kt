package com.gongmanse.app.utils

import androidx.recyclerview.widget.DiffUtil
import com.gongmanse.app.model.VideoData

class ListItemDiffCallback(private val oldListItems: ArrayList<VideoData>, private val newListItems: ArrayList<VideoData>): DiffUtil.Callback() {

    override fun getOldListSize(): Int {
        return oldListItems.size
    }

    override fun getNewListSize(): Int {
        return newListItems.size
    }

    override fun areItemsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
        val oldItem = oldListItems[oldItemPosition]
        val newItem = newListItems[newItemPosition]
        return oldItem == newItem
    }

    override fun areContentsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {

        return true
    }

}