package com.gongmanse.app.adapter.notice

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.NoticeDetailWebViewActivity
import com.gongmanse.app.adapter.bindViewImgTag
import com.gongmanse.app.adapter.bindViewURLImage
import com.gongmanse.app.databinding.ItemNoticeBinding
import com.gongmanse.app.fragments.notice.NoticeFragment
import com.gongmanse.app.model.NoticeData
import com.gongmanse.app.utils.Constants
import org.jetbrains.anko.intentFor
import java.util.regex.Matcher
import java.util.regex.Pattern

class NoticeRVAdapter : RecyclerView.Adapter<NoticeRVAdapter.ViewHolder>(){

    companion object {
        private val TAG = NoticeRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<NoticeData> = ArrayList()
    private var imgTags: String? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_notice, parent, false
            )
        )
    }

    fun addItems(newItems: List<NoticeData>) {
        Log.e(TAG, "newItems => $newItems")
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun setImgTag(tag: String?) {
        if (tag != null) {
            val pattern: Pattern = Pattern.compile("<img[^>]*src=[\"']?([^>\"']+)[\"']?[^>]*>")
            val matcher: Matcher = pattern.matcher(tag)
            if (matcher.find()) {
                imgTags = matcher.group(1)
            }
        } else Log.e(TAG, "Imgtag is null")
    }


    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        Log.d(TAG, "onBindViewHolder")
        val item = items[position]
        holder.apply {
            bind(item) {
                itemView.context.apply {
                    startActivity(
                        intentFor<NoticeDetailWebViewActivity>(
                            Constants.EXTRA_KEY_NOTICE to item
                        )
                    )
                }
            }
        }
    }

    inner class ViewHolder(private val binding: ItemNoticeBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: NoticeData, listener: View.OnClickListener) {
            binding.apply {
                this.notice = data
                this.layoutRoot.setOnClickListener(listener)
                setImgTag(data.contentImg)
                bindViewImgTag(this.imageView, imgTags)
            }
        }


    }

}