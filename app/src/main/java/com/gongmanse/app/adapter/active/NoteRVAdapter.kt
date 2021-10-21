package com.gongmanse.app.adapter.active

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.activities.SettingActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.activities.VideoNoteActivity
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemNoteBinding
import com.gongmanse.app.fragments.active.ActiveNoteFragment
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.IsWIFIConnected
import com.gongmanse.app.utils.Preferences
import kotlinx.android.synthetic.main.item_video.view.*
import okhttp3.ResponseBody
import org.jetbrains.anko.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class NoteRVAdapter(private val context: ActiveNoteFragment) : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        private val TAG = NoteRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<VideoData> = ArrayList()
    private var sortId : Int? = null
    private var isChecked: Boolean = false
    private var totalItemNum : Int = 0

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemNoteBinding.inflate(LayoutInflater.from(parent.context), parent, false)
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
            itemView.tag = item
            bind(item
                , {
                    Log.d(TAG, "item removed => $position")
                    itemView.context.apply {
                        alert(message = "삭제 하시겠습니까?") {
                            noButton { it.dismiss() }
                            yesButton { removeItem(position) }
                        }.show()
                    }
                }
                , {
                    when(it){
                        it.iv_quick_video ->{
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
                                    if (item.iActive == "1") {
                                        val intent = Intent(this, VideoActivity::class.java)
                                        intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, item.videoId ?: item.id)
                                        intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)
                                        startActivity(intent)
                                    } else {
                                        Toast.makeText(this, "해당 강의는 취소되었습니다.", Toast.LENGTH_SHORT).show()
                                    }
                                }
                            }
                        }
                        else ->{
                            (itemView.context as Activity).apply {
                                val intent = Intent(itemView.context, VideoNoteActivity::class.java)
                                intent.putExtra(Constants.EXTRA_KEY_SEARCH_NOTE, items)
                                intent.putExtra("position", position)
                                intent.putExtra("type", Constants.NOTE_TYPE_ACTIVE)
                                intent.putExtra(Constants.EXTRA_KEY_TOTAL_NUM,totalItemNum)
                                startActivityForResult(intent, 9001)
                            }
                        }
                    }
                }
            )
        }
    }

    private fun removeItem(position: Int) {
        RetrofitClient.getService().removeNote(Preferences.token, items[position].id!!).enqueue(object: Callback<ResponseBody> {
            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.v(TAG, "onResponse => $this")
                        items.removeAt(position)
                        context.updateTotalNum(true)
                        notifyItemRemoved(position)
                        notifyItemRangeChanged(position, items.size)
                        if (items.size < 1) context.onRefresh()
                    }
                }
            }
        })
    }

    fun addSortId(sortId : Int?){
        this.sortId = sortId
    }

    fun addTotal(total : Int){
        totalItemNum = total
    }
    fun addItems(newItems: List<VideoData>) {
        Log.d(TAG, "isChecked => $isChecked")
        for (item in newItems) {
            item.isRemove = isChecked
        }
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun addItem(newItem: VideoData) {
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
        val item = VideoData().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
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

    private class ItemViewHolder (private val binding : ItemNoteBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoData, remove: View.OnClickListener, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                ivRemove.setOnClickListener(remove)
                layoutRoot.setOnClickListener(listener)
                ivQuickVideo.setOnClickListener(listener)
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