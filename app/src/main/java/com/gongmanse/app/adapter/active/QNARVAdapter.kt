package com.gongmanse.app.adapter.active

import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.activities.SettingActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemQnaBinding
import com.gongmanse.app.fragments.active.ActiveQNAFragment
import com.gongmanse.app.model.QNAData
import com.gongmanse.app.model.VideoQuery
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.IsWIFIConnected
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class QNARVAdapter(private val activity: ActiveQNAFragment) : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        private val TAG = QNARVAdapter::class.java.simpleName
    }

    private val items: ArrayList<QNAData> = ArrayList()
    private var sortId : Int? = null
    private var isChecked: Boolean = false

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemQnaBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ItemViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int) = position.toLong()

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ItemViewHolder) {
            populateItemRows(holder, position)
        } else if (holder is LoadingViewHolder) {
            showLoadingView(holder, position)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {

    }

    private fun populateItemRows(holder: ItemViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item
                , {
                    Log.d(TAG, "item removed => $position")
                    activity.showQnaList(item.id.toString(), item.title!!)
                }
                , {
                    val wifiState = IsWIFIConnected().check(holder.itemView.context)
                    itemView.context.apply {
                        Log.d("입구", "어댑터 클릭 ${item.id}")
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
                            val intent = Intent(this, VideoActivity::class.java)
                            intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, item.videoId ?: item.id)
                            intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)
                            startActivity(intent)
                        }
                    }
                }
            )
        }
    }

    fun addSortId(sortId : Int?){
        this.sortId = sortId
    }

    fun addItems(newItems: List<QNAData>) {
        Log.d(TAG, "isChecked => $isChecked")
        for (item in newItems) {
            item.isRemove = isChecked
        }
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun addItem(newItem: QNAData) {
        Log.d(TAG, "isChecked => $isChecked")
        newItem.isRemove = true
        items.add(newItem)
        notifyItemInserted(items.size)
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun setRemoveMode() {
        isChecked = isChecked.not()
        Log.d(TAG, "setRemoveState(): isChecked => $isChecked")
        for (item in items) {
            item.isRemove = isChecked
        }
        notifyDataSetChanged()
    }

    fun setNormalMode() {
        isChecked = false
        Log.d(TAG, "setNormalMode(): isChecked => $isChecked")
        for (item in items) {
            item.isRemove = isChecked
        }
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

    private class ItemViewHolder (private val binding : ItemQnaBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : QNAData, remove: View.OnClickListener, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                ivRemove.setOnClickListener(remove)
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