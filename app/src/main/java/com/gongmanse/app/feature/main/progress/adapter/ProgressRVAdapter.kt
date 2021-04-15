package com.gongmanse.app.feature.main.progress.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.data.model.progress.ProgressBody
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemProgressBinding

class ProgressRVAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    companion object {
        private val TAG = ProgressRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<ProgressBody> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        TODO("Not yet implemented")
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        TODO("Not yet implemented")
    }

    override fun getItemCount(): Int {
        TODO("Not yet implemented")
    }

    private class ItemViewHolder (private val binding : ItemProgressBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(data: ProgressBody) {
            binding.apply {

            }
        }
    }

    private class LoadingViewHolder (private val binding: ItemLoadingBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind() { binding.apply {}}
    }

}