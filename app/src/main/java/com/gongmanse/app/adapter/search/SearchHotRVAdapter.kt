package com.gongmanse.app.adapter.search

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemSearchHotBinding
import com.gongmanse.app.listeners.OnSearchKeywordListener
import com.gongmanse.app.model.SearchHotListData
import kotlinx.android.synthetic.main.item_search_hot.view.*

class SearchHotRVAdapter(private val listener: OnSearchKeywordListener) : RecyclerView.Adapter<SearchHotRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = SearchHotRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<SearchHotListData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_search_hot,
                parent,
                false
            )
        )
    }

    fun addItems(newItems: List<SearchHotListData>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item) {
                if (item.keyword.isNotEmpty()) listener.onSearchKeyword(item.keyword)
                Log.d(TAG, "Hot Keyword => ${item.keyword}")
            }

        }
    }

    inner class ViewHolder(private val binding: ItemSearchHotBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(data: SearchHotListData, listener: View.OnClickListener){
            binding.apply {
                this.search = data
                itemView.setOnClickListener(listener)

                Log.d(TAG,"Item.id => ${data.id}")
                if (data.id in 1..3) itemView.cv_number.setCardBackgroundColor(ContextCompat.getColor(itemView.context, R.color.main_color))
                else itemView.cv_number.setCardBackgroundColor(ContextCompat.getColor(itemView.context, R.color.gray))
            }

        }
    }
}