package com.gongmanse.app.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemTeacherBinding
import com.gongmanse.app.model.Teacher

class TeacherIntroRVAdapter : RecyclerView.Adapter<TeacherIntroRVAdapter.ViewHolder> (){

    companion object {
        private val TAG = TeacherIntroRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<Teacher> = ArrayList()


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_teacher,
                parent,
                false
            )
        )
    }

    fun addItems(newItems: List<Teacher>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }


    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item)
        }
    }

    inner class ViewHolder(private val binding: ItemTeacherBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(data: Teacher) {
            binding.apply {
                this.data = data
            }
        }
    }
}