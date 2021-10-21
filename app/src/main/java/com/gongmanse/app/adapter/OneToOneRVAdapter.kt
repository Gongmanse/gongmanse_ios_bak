package com.gongmanse.app.adapter

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.activities.customer.CustomerServiceDetailActivity
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemOneToOneBinding
import com.gongmanse.app.model.OneToOneData
import com.gongmanse.app.utils.Constants
import org.jetbrains.anko.intentFor

class OneToOneRVAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {


    companion object {
        private val TAG = OneToOneRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<OneToOneData> = ArrayList()


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding =
                ItemOneToOneBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ItemViewHolder(binding)

        } else {
            val binding =
                ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is ItemViewHolder -> populateItemRows(holder, position)
            is LoadingViewHolder -> showLoadingView(holder, position)
        }
    }

    override fun getItemCount(): Int = items.size


    fun addItems(newItems: List<OneToOneData>) {
        Log.e(TAG, "newItems => $newItems")
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun addLoading() {
        val item = OneToOneData().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
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

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {}

    private fun populateItemRows(holder: ItemViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item, View.OnClickListener {
                itemView.context.apply { startActivity(intentFor<CustomerServiceDetailActivity>(Constants.EXTRA_KEY_ONE_TO_ONE to item)) }
            })
        }
    }

    private class ItemViewHolder(private val binding: ItemOneToOneBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: OneToOneData, listener: View.OnClickListener) {
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
            }
        }
    }

    private class LoadingViewHolder(private val binding: ItemLoadingBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind() {
            binding.apply {}
        }
    }

}