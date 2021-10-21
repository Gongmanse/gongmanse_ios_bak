package com.gongmanse.app.adapter

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.LoginActivity
import com.gongmanse.app.activities.RelationSeriesActivity
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemVideoBinding
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class RelationSeriesRVAdapter(private val activity: RelationSeriesActivity) : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        private val TAG = RelationSeriesRVAdapter::class.java.simpleName
        private val items: ObservableArrayList<VideoData> = ObservableArrayList()
        private var isAutoPlay: Boolean = true
        private var seriesId: Int = 0
        private val bottomQuery = hashMapOf<String,Any?>()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemVideoBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ItemViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ItemViewHolder) {
            populateItemRows(holder, position)
        } else if (holder is LoadingViewHolder) {
            showLoadingView(holder, position)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {

    }

    private fun populateItemRows(holder: ItemViewHolder, position: Int) {
        holder.bind(items[position], View.OnClickListener {
            items[position]?.let {
                Log.e(TAG, "items[${position}] => $it")
                Preferences.currentPosition = position
                if (Preferences.token.isNotEmpty()) {
                    activity.backToVideo(it.id,it.seriesId,position,isAutoPlay)
                } else {
                    activity.apply {
                        alert(title = null, message = getString(R.string.content_text_toast_login)) {
                            positiveButton(getString(R.string.content_button_positive)) { dialog ->
                                dialog.dismiss()
                                startActivity(intentFor<LoginActivity>().singleTop())
                            }
                        }.show()
                    }
                }
            }
        })
    }

    fun setSeriesId(id: Int) {
        seriesId = id
    }

    fun addBottomInfo(query : HashMap<String,Any?>){
        bottomQuery.putAll(query)
    }

    fun setAutoPlay(isActive: Boolean) {
        isAutoPlay = isActive
    }

    fun getAutoPlay() = isAutoPlay

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

    fun addItems(newItems: ObservableArrayList<VideoData>?) {
        newItems?.let {
            val position = items.size
            items.addAll(it)
            notifyItemRangeInserted(position, it.size)
        }
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    private class ItemViewHolder (private val binding : ItemVideoBinding) : RecyclerView.ViewHolder(binding.root){
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