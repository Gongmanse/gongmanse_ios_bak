package com.gongmanse.app.adapter.home

import android.content.Intent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.MainActivity
import com.gongmanse.app.activities.SettingActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemVideoBinding
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.utils.*
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop


class HomeHotRVAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    private val items: ArrayList<VideoData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemVideoBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int) = position.toLong()

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ViewHolder) {
            populateItemRows(holder, position)
        } else if (holder is LoadingViewHolder) {
            showLoadingView(holder, position)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {
        holder.apply {
            bind()
        }
    }

    private fun populateItemRows(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            GBLog.d("RecyclerViewHolder", "setTag")
            itemView.tag = holder

            bind(item, View.OnClickListener {
                val wifiState = IsWIFIConnected().check(holder.itemView.context)
                itemView.context.apply {
                    if (Preferences.token.isEmpty()) {
                        alert(title = null, message = getString(R.string.content_text_toast_login)) {
                            positiveButton(getString(R.string.content_button_positive)) {
                                it.dismiss()
                                (holder.itemView.context as MainActivity).openDrawer()
                            }
                        }.show()
                    } else {
                        if (item.seriesCount == 0) {
                            if (!Preferences.mobileData && !wifiState) {
                                alert(
                                    title = null,
                                    message = " WIFI 를 연결하거나, 설정에서 모바일 데이터 사용을 허용해주세요"
                                ) {
                                    positiveButton("설정") {
                                        it.dismiss()
                                        startActivity(intentFor<SettingActivity>().singleTop())
                                    }
                                    negativeButton("닫기") {
                                        it.dismiss()
                                    }
                                }.show()
                            } else {
                                item.id?.let {
                                    val intent = Intent(this, VideoActivity::class.java)
                                    intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)
                                    intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, it)
                                    intent.putExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_HOT)
//                                    intent.putExtra(Constants.EXTRA_KEY_NOW_POSITION,position)
                                    startActivity(intent)
                                }
                            }
                        }
                    }
                }
            })
        }
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun addItems(newItems: List<VideoData>) {
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun addLoading() {
        val item = VideoData().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
        items.add(item)
        notifyDataSetChanged()
//        notifyItemInserted(items.size - 1)
    }

    fun removeLoading() {
        val position = items.size - 1
        if (items[position].itemType == Constants.VIEW_TYPE_LOADING) {
            items.removeAt(position)
            val scrollPosition = items.size
            notifyItemRemoved(scrollPosition)
        }
    }

    private class ViewHolder (private val binding : ItemVideoBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoData, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
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