package com.gongmanse.app.feature.main.home.tabs

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.data.model.video.Body
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemVideoBinding
import com.gongmanse.app.databinding.ItemVideoNoteBinding
import com.gongmanse.app.databinding.ItemVideoSeriesBinding
import com.gongmanse.app.utils.Constants

class HomeSubjectRVAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        const val REQUEST_CODE = 9001
    }

    private val items: ArrayList<Body> = ArrayList()
    private var auto = false
    private var type : Int? = null
    private var sortId : Int? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when(viewType){
            Constants.ViewType.DEFAULT -> {
                val binding = ItemVideoBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                VideoViewHolder(binding)
            }
            Constants.ViewType.LOADING ->{
                val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                LoadingViewHolder(binding)
            }
            Constants.ViewType.SERIES ->{
                val binding = ItemVideoSeriesBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                SeriesViewHolder(binding)
            }
            Constants.ViewType.NOTE ->{
                val binding = ItemVideoNoteBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                NoteViewHolder(binding)
            }
            else ->{
                val binding = ItemVideoBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                VideoViewHolder(binding)
            }
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int) = position.toLong()

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val item = items[position]
        when(holder){
            is VideoViewHolder -> {
                holder.apply {
                    bind(item, View.OnClickListener{

                    })
                }
            }
            is NoteViewHolder -> {
                holder.apply {
                    bind(item, View.OnClickListener{

                    })
                }
            }
            is SeriesViewHolder -> {
                holder.apply {
                    bind(item, View.OnClickListener{

                    })
                }
            }
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].viewType
    }

    fun clear(){
        items.clear()
        notifyDataSetChanged()
    }

    fun addSortId(sortId : Int?){
        this.sortId = sortId
    }

    fun autoPlay(bool : Boolean){
        auto = bool
    }

    fun addItems(newItems: List<Body>) {
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun addLoading() {
        val item = Body().apply { this.viewType = Constants.ViewType.LOADING }
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

    private class VideoViewHolder (private val binding : ItemVideoBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : Body, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                layoutItems.setOnClickListener(listener)
            }
        }
    }

    private class NoteViewHolder (private val binding : ItemVideoNoteBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : Body, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                layoutItems.setOnClickListener(listener)
                ivQuickVideo.setOnClickListener(listener)
            }
        }
    }

    private class SeriesViewHolder (private val binding : ItemVideoSeriesBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : Body, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                layoutItems.setOnClickListener(listener)
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