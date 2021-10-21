package com.gongmanse.app.adapter.teacher

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.TeacherListActivity
import com.gongmanse.app.databinding.ItemTeacherBinding
import com.gongmanse.app.model.Teacher
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class TeacherERvAdapter : RecyclerView.Adapter<TeacherERvAdapter.ViewHolder>() {


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

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item) {
                itemView.context.apply {
                    startActivity(
                        intentFor<TeacherListActivity>(
                            "teacher" to item,
                            "grade" to "초등"
                        ).singleTop()
                    )
                }
            }
        }
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun addItems(newItems: List<Teacher>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }


    class ViewHolder(private val binding: ItemTeacherBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: Teacher, listener: View.OnClickListener) {
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
            }
        }
    }

}