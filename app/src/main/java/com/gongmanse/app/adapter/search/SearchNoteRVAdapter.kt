package com.gongmanse.app.adapter.search

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.*
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemNoteBinding
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.IsWIFIConnected
import com.gongmanse.app.utils.Preferences
import kotlinx.android.synthetic.main.item_note.view.*
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.startActivityForResult

class SearchNoteRVAdapter(private val context: Activity) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    companion object {
        private val TAG = SearchNoteRVAdapter::class.java.simpleName
        const val REQUEST_CODE = 9002
        const val REQUEST_CODE_LOGIN = 9002
    }

    private val items: ArrayList<VideoData> = ArrayList()
    private var auto = false
    private var grade: String? =""
    private var subjectId = 0
    private var keyword: String? = ""
    private var sortId :Int = Constants.CONTENT_RESPONSE_VALUE_LATEST
    private var totalItemNum : Int = 0

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding =
                ItemNoteBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ItemViewHolder(binding)
        } else {
            val binding =
                ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    fun addNoteData(grade: String?, subjectId: Int?, keyword: String?, sortId: Int){
        this.grade = grade
        this.subjectId = subjectId ?: 0
        this.keyword = keyword
        this.sortId = sortId
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is ItemViewHolder -> populateItemRows(holder, position)
            is LoadingViewHolder -> showLoadingView(holder, position)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    fun addItems(newItems: List<VideoData>) {
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun autoPlay(boolean: Boolean) {
        auto = boolean
    }

    fun addLoading() {
        val item = VideoData().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
        items.add(item)
        notifyItemInserted(items.size - 1)
    }

    fun addTotal(total : Int){
        totalItemNum = total
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
            bind(item) {
                val wifiState = IsWIFIConnected().check(holder.itemView.context)
                itemView.context.apply {
                    if (Preferences.token.isEmpty()) {
                        alert(
                            title = null,
                            message = getString(R.string.content_text_toast_login)
                        ) {
                            positiveButton(getString(R.string.content_button_positive)) {
                                it.dismiss()
                                this@SearchNoteRVAdapter.context.apply {
                                    val intent = Intent(this, LoginActivity::class.java)
                                    startActivityForResult(intent, REQUEST_CODE_LOGIN)
                                }
                            }
                        }.show()
                    } else {
                        val activity = (this as SearchResultActivity)
                        activity.goToVideoInAdapter()
                        when (it) {
                            it.iv_quick_video -> {
                                if (!Preferences.mobileData && !wifiState) {
                                    wifiAlert(holder)
                                } else {
                                    val intent = Intent(this, VideoActivity::class.java)
                                    intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)
                                    intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, item.id ?: item.videoId)
                                    intent.putExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_NOTE)
                                    intent.putExtra(Constants.EXTRA_KEY_BACK_PRESSED, "back")
                                    context.startActivityForResult(intent, REQUEST_CODE)
                                }
                            }
                            else -> {
                                val intent = Intent(context, VideoNoteActivity::class.java)
                                intent.putExtra(Constants.EXTRA_KEY_SEARCH_NOTE, items)
                                intent.putExtra(Constants.EXTRA_KEY_POSITION, position)
                                intent.putExtra(Constants.EXTRA_KEY_GRADE, grade)
                                intent.putExtra(Constants.EXTRA_KEY_SUBJECT_ID, subjectId)
                                intent.putExtra(Constants.EXTRA_KEY_KEYWORD, keyword)
                                intent.putExtra(Constants.EXTRA_KEY_SORT_ID, sortId)
                                intent.putExtra(Constants.EXTRA_KEY_TOTAL_NUM, totalItemNum)
                                intent.putExtra(Constants.EXTRA_KEY_TYPE2, Constants.NOTE_TYPE_SEARCH)
                                context.startActivityForResult(intent, REQUEST_CODE)
                            }
                        }
                    }
                }
            }
        }
    }

    private class ItemViewHolder(private val binding: ItemNoteBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: VideoData, listener: View.OnClickListener) {
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
                ivQuickVideo.setOnClickListener(listener)
            }
        }
    }

    private fun wifiAlert(holder: ItemViewHolder){
        holder.itemView.context.apply {
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
        }
    }

    private class LoadingViewHolder(private val binding: ItemLoadingBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind() { binding.apply {} }
    }

}