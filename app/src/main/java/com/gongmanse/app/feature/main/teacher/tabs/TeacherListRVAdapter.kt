package com.gongmanse.app.feature.main.teacher.tabs

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.data.model.teacher.TeacherBody
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemTeacherBinding
import com.gongmanse.app.utils.Constants

class TeacherListRvAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder> () {


    private val items: ArrayList<TeacherBody> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.ViewType.DEFAULT) {
            val binding =
                ItemTeacherBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            TeacherViewHolder(binding)

        } else {
            val binding =
                ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is TeacherViewHolder -> populateItemRows(holder, position)
        }
    }

    private fun populateItemRows(holder: TeacherViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item, View.OnClickListener {

            })
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].viewType
    }

    fun clear(){
        items.clear()
        notifyDataSetChanged()
    }

    fun addItems(newItems: ArrayList<TeacherBody>) {
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun addLoading() {
        val item = TeacherBody().apply { this.viewType = Constants.ViewType.LOADING }
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

    private class TeacherViewHolder (private val binding : ItemTeacherBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : TeacherBody,listener: View.OnClickListener){
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
            }
        }
    }
    private class LoadingViewHolder(private val binding: ItemLoadingBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind() {
            binding.apply {}
        }
    }

}