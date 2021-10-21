package com.gongmanse.app.adapter.video

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemPlayListBinding
import com.gongmanse.app.fragments.video.VideoPlayListFragment1
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.ListItemDiffCallback

class PlayListRVAdapter1(private val activity: VideoPlayListFragment1) : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    private val items: ArrayList<VideoData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemPlayListBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ViewHolder) {
            populateItemRows(holder, position)
        } else if (holder is LoadingViewHolder) {
            showLoadingView(holder, position)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {

    }

    private fun populateItemRows(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            itemView.tag = item
            bind(item, View.OnClickListener {
                if (item.isFocusing.not()) {
                    activity.setVideo(item.videoId ?: item.id, item.seriesId, position)
                }
            })
        }
    }

    fun addLoading() {
        val item = VideoData().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
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

    fun updateItems(items: ObservableArrayList<VideoData>?) {
        if (items != null) {
            val callback = ListItemDiffCallback(this.items, items)
            val result = DiffUtil.calculateDiff(callback)
            this.items.clear()
            this.items.addAll(items)
            result.dispatchUpdatesTo(this)
        }
    }

    fun unSelectedItem(position: Int) {
        if (items.size > 0) {
            this.items[position].isFocusing = false
            notifyItemChanged(position)
        }
    }

    fun selectedItem(position: Int) {
        if (items.size > 0) {
            this.items[position].isFocusing = true
            notifyItemChanged(position)
        }
    }

    fun addItems(values: ObservableArrayList<VideoData>?) {
        val position = items.size
        Log.d("PlayListRVAdapter", "position => $position")
        Log.d("PlayListRVAdapter", "addItems data size => ${values?.size}")
        values?.let {
            items.addAll(it)
            notifyItemRangeInserted(position, it.size)
        }
    }

    fun getItems(): ArrayList<VideoData> {
        return items
    }

    fun clear() {
        Log.d("PlayListRVAdapter1", "@@@### clear....")
        items.clear()
        notifyDataSetChanged()
    }

    private class ViewHolder (private val binding : ItemPlayListBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoData, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
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