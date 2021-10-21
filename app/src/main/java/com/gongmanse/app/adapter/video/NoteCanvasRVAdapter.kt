package com.gongmanse.app.adapter.video

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemNoteCanvasBinding

class NoteCanvasRVAdapter : RecyclerView.Adapter<NoteCanvasRVAdapter.ViewHolder> () {

    private val items: ArrayList<String> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_note_canvas,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item)
            itemView.tag = item
        }
    }

    fun addItems(newItems: List<String>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    class ViewHolder (private val binding : ItemNoteCanvasBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : String){
            binding.apply {
                this.data = data
            }
        }
    }

}