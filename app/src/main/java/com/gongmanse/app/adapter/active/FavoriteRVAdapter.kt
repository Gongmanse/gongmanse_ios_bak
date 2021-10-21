package com.gongmanse.app.adapter.active

import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.SettingActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.adapter.RelationSeriesRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ItemFavoriteBinding
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemVideoBinding
import com.gongmanse.app.fragments.active.ActiveFavoritesFragment
import com.gongmanse.app.fragments.active.ActiveQuestionFragment
import com.gongmanse.app.listeners.OnHeaderListener
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoQuery
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.IsWIFIConnected
import com.gongmanse.app.utils.Preferences
import okhttp3.ResponseBody
import org.jetbrains.anko.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class FavoriteRVAdapter(private val context: ActiveFavoritesFragment) : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        private val TAG = FavoriteRVAdapter::class.java.simpleName
    }

    private val items: ObservableArrayList<VideoData> = ObservableArrayList()
    private var sortId : Int? = null
    private var isChecked: Boolean = false
    private var isAutoPlay: Boolean = false

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemFavoriteBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ItemViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int) = position.toLong()

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ItemViewHolder) {
            populateItemRows(holder, position)
        } else if (holder is LoadingViewHolder) {
            showLoadingView(holder, position)
        }
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
                }, {
                    val wifiState = IsWIFIConnected().check(holder.itemView.context)
                    itemView.context.apply {
                        Log.d("입구","어댑터 클릭 ${item.id}")
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
                        }else {
                            val intent = Intent(this, VideoActivity::class.java)
                            intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, item.videoId ?: item.id)
                            intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)
                            if(isAutoPlay){
                                intent.putExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_FAVORITE)
                                intent.putExtra(Constants.EXTRA_KEY_SORTING, sortId)
                                intent.putExtra(Constants.EXTRA_KEY_NOW_POSITION, position)
                            }
                            startActivity(intent)
                        }
                    }
                })
        }
    }

    private fun removeItem(position: Int) {
        RetrofitClient.getService().removeFavorite(Preferences.token, items[position].bookmarkId!!).enqueue(object: Callback<ResponseBody> {
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
        Log.d(TAG, "newItem => $newItem")
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

    fun setAutoPlay(isActive: Boolean) {
        this.isAutoPlay = isActive
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

    private class ItemViewHolder (private val binding : ItemFavoriteBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoData, remove: View.OnClickListener, listener: View.OnClickListener){
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