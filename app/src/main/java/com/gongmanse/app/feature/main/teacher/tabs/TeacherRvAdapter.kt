package com.gongmanse.app.feature.main.teacher.tabs

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.data.model.video.VideoBody
import com.gongmanse.app.databinding.ItemTeacherBinding

class TeacherRvAdapter : RecyclerView.Adapter<TeacherRvAdapter.ViewHolder> () {


    private val items: ArrayList<VideoBody> = ArrayList()

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

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
//            bind(item,View.OnClickListener {
//                itemView.context.apply { startActivity(intentFor<TeacherListActivity>("teacher" to item
//                ).singleTop()) }
//            })
        }
    }

    fun clear(){
        items.clear()
        notifyDataSetChanged()
    }

    fun addItems(newItems: ArrayList<VideoBody>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }


    class ViewHolder (private val binding : ItemTeacherBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoBody,listener: View.OnClickListener){
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
            }
        }
    }

}