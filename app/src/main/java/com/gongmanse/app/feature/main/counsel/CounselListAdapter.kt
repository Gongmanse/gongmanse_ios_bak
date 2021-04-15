package com.gongmanse.app.feature.main.counsel

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.data.model.video.VideoBody
import com.gongmanse.app.databinding.ItemCounselBinding
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.utils.Constants
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class CounselListAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {


    private val items: ArrayList<VideoBody> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.ViewType.DEFAULT) {
            val binding = ItemCounselBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ItemViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when(holder) {
            is ItemViewHolder    -> populateItemRows(holder, position)
            is LoadingViewHolder -> showLoadingView(holder, position)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].viewType
    }

    fun clear(){
        items.clear()
        notifyDataSetChanged()
    }
    fun addItems(newItems: List<VideoBody>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun addLoading() {
        val item = VideoBody().apply { this.viewType = Constants.ViewType.LOADING }
        items.add(item)
        notifyItemInserted(items.size - 1)
    }

    fun removeLoading() {
        val position = items.size - 1
        if (items[position].viewType == Constants.ViewType.LOADING) {
            items.removeAt(position)
            val scrollPosition = items.size
            notifyItemRemoved(scrollPosition)
        }
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {}

    private fun populateItemRows(holder: ItemViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item, View.OnClickListener {
//                itemView.context.apply { startActivity(intentFor<CounselDetailActivity>(Constants.EXTRA_KEY_COUNSEL to item).singleTop()) }
            })
        }
    }

    private class ItemViewHolder (private val binding : ItemCounselBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoBody, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
            }
        }
    }

    private class LoadingViewHolder (private val binding : ItemLoadingBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(){ binding.apply {} }
    }

}