package com.gongmanse.app.adapter.counsel

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.databinding.ItemCounselMediaImageBinding
import com.gongmanse.app.databinding.ItemCounselMediaVideoBinding
import com.gongmanse.app.utils.Constants
import org.koin.core.logger.KOIN_TAG


class CounselVPAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    private val items: ArrayList<String> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        Log.d("viewType 들어온것" , "$viewType")
        when (viewType) {
            Constants.COUNSEL_TYPE_IMAGE -> {
                val binding = ItemCounselMediaImageBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return ImageHolder(binding)
            }
            else -> {
                val binding = ItemCounselMediaVideoBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return VideoHolder(binding)
            }
        }
    }
    fun addItems(newItems: List<String>) {
        Log.e("CounselVPAdapter", "$newItems" )
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val item = items[position]
        when(holder) {
            is ImageHolder ->{
                holder.apply {
                    bind(item)
                }
            }
            is VideoHolder ->{
                holder.apply {
                    bind(item)
                }
            }
        }
    }
    override fun getItemViewType(position: Int): Int {
        items[position].let {
            return if(it.endsWith(".mp4")){
                Constants.COUNSEL_TYPE_VIDEO
            }else{
                Constants.COUNSEL_TYPE_IMAGE
            }
        }
    }

    class VideoHolder(private val binding: ItemCounselMediaVideoBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: String?) {
            binding.apply {
                this.data = item
                binding.ivDelete.visibility = View.GONE
            }
        }
    }

    class ImageHolder(private val binding: ItemCounselMediaImageBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: String?) {
            binding.apply {
                Log.e("tag", "$item")
                this.data = item
                binding.ivDelete.visibility = View.GONE
            }
        }
    }
}