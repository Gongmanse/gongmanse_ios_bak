package com.gongmanse.app.feature.main.home.tabs

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.data.model.Body
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
            Constants.VIEW_TYPE_ITEM -> {
                val binding = ItemVideoBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                VideoViewHolder(binding)
            }
            else ->{
                val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                LoadingViewHolder(binding)
            }
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int) = position.toLong()

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is VideoViewHolder) {
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

    private fun populateItemRows(holder: VideoViewHolder, position: Int) {
        val item = items[position]

        holder.apply {
            bind(item, View.OnClickListener{

            })
        }
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
        val item = Body().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
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