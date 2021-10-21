package com.gongmanse.app.adapter.video

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemNoteBinding
import com.gongmanse.app.model.NoteData

class NoteRVAdapter : RecyclerView.Adapter<NoteRVAdapter.ViewHolder> () {

//    private val items: ArrayList<NoteData> = ArrayList()
    private val items: ArrayList<NoteData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_note,
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

    fun addItems(newItems: List<NoteData>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    class ViewHolder (private val binding : ItemNoteBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : NoteData){
            binding.apply {
//                this.data = data
            }
        }
    }

}