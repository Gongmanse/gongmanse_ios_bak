package com.gongmanse.app.feature.main.progress.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.databinding.ItemVideoBinding


class ProgressDetailRVAdapter : RecyclerView.Adapter<ProgressDetailRVAdapter.ViewHolder>() {

    // 공용 Adapter랑 통일
    // Item_video 를 사용하는 Model 통일

    companion object {
        private val TAG = ProgressDetailRVAdapter::class.java.simpleName
    }

    private var auto = false

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        TODO("Not yet implemented")
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        TODO("Not yet implemented")
    }

    override fun getItemCount(): Int {
        TODO("Not yet implemented")
    }

    inner class ViewHolder(private val binding: ItemVideoBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind() {

        }
    }
}