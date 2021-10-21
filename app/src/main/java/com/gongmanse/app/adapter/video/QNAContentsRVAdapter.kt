package com.gongmanse.app.adapter.video

import android.util.Log
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemQuestionAndAnswerBinding
import com.gongmanse.app.model.QNAData
import com.gongmanse.app.utils.Constants

class QNAContentsRVAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        private val TAG = QNAContentsRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<QNAData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemQuestionAndAnswerBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ViewHolder) {
//            Log.e(TAG, "onBindViewHolder1...position => $position | $holder")
            populateItemRows(holder, position)
        } else if (holder is LoadingViewHolder) {
            showLoadingView(holder, position)
        }
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {}

    private fun populateItemRows(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            itemView.tag = item
            bind(item)
        }
    }

    fun getItemSize(): Int {
        return items.size
    }

    fun addItems(newItems: List<QNAData>?) {
        newItems?.let {
            val position = items.size
            items.addAll(it)
            notifyItemRangeInserted(position, it.size)
        }
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun addLoading() {
        val item = QNAData().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
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

    private class ViewHolder (private val binding : ItemQuestionAndAnswerBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : QNAData){
            binding.apply {
                this.data = data
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