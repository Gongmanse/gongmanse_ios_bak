package com.gongmanse.app.adapter

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemFaqBinding
import com.gongmanse.app.model.FAQData
import com.gongmanse.app.utils.ToggleAnimation
import kotlinx.android.synthetic.main.item_faq.view.*

class FAQRVAdapter : RecyclerView.Adapter<FAQRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = FAQRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<FAQData> = ArrayList()
    private var context: Context? = null
    private var position: Int? = 0

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        context = parent.context
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_faq,
                parent,
                false
            )
        )
    }

    fun addItems(newItems: List<FAQData>) {
        Log.e(TAG, "newItems => $newItems")
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
            bind(item, position, View.OnClickListener {
                val show = toggleLayout(item.isExpanded.not(), it, itemView.layout_answer)
                item.isExpanded = show
            })
        }
    }


    inner class ViewHolder(private val binding: ItemFaqBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: FAQData, position: Int, listener: View.OnClickListener) {
            binding.apply {
                this.data = data
                this@FAQRVAdapter.position = position
                this.layoutQuestion.setOnClickListener(listener)
            }
        }
    }

    private fun toggleLayout(isExpanded: Boolean, view: View, layoutExpand: ConstraintLayout) : Boolean {
        ToggleAnimation.toggleArrow(view, isExpanded)
        if (isExpanded) {
            ToggleAnimation.expand(layoutExpand)
        } else {
            ToggleAnimation.collapse(layoutExpand)
        }
        return isExpanded
    }

}