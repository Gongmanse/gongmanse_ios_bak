package com.gongmanse.app.adapter.search

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.LoginActivity
import com.gongmanse.app.activities.SearchResultActivity
import com.gongmanse.app.activities.SettingActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemSearchVideoBinding
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.IsWIFIConnected
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class SearchVideoLoadingRVAdapter(private val context: Activity, private val from: Boolean) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    /*from
    * true  -> SearchMainActivity
    * false -> LectureActivity
    * */

    private val items: ArrayList<VideoData> = ArrayList()
    private var bottomQuery = hashMapOf<String,Any?>()

    private var auto = false
    private var sortId : Int? = null
    private var subjectId: Int? = null
    private var searchGrade: String? = null
    private var searchKeyword: String? = null
    private var searchOffset : String? = null

    companion object{
        private val TAG = SearchVideoLoadingRVAdapter::class.java.simpleName
        const val REQUEST_CODE = 1
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemSearchVideoBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ItemViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when(holder) {
            is ItemViewHolder    -> populateItemRows(holder, position)
            is LoadingViewHolder -> showLoadingView(holder, position)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    fun videoBottomVideoInfo(bottomQuery : HashMap<String,Any?>){
        this.bottomQuery = bottomQuery
    }

    fun addItems(newItems: List<VideoData>) {
        Log.e(TAG, "newItems => $newItems")
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun autoPlay(boolean: Boolean) { auto = boolean}

    fun searchInfo(sort_id: Int? ,subject_id: Int?, grades: String?, keywords: String?, offset: String?) {
        sortId = sort_id
        subjectId = subject_id
        searchGrade = grades
        searchKeyword = keywords
        searchOffset = offset
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
                                this@SearchVideoLoadingRVAdapter.context.apply {
                                    val intent = Intent(this, LoginActivity::class.java)
                                    startActivityForResult(intent, REQUEST_CODE)
                                }
                            }
                        }.show()
                    } else {
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
                            if (from) {
                                Log.e(TAG, "From is false")
                                itemView.context.apply {
                                    val intent = Intent(this, VideoActivity::class.java)
                                    Constants.apply {
                                        // Commons Info
                                        intent.putExtra(EXTRA_KEY_VIDEO_ID, item.videoId ?: item.id)
                                        intent.putExtra(EXTRA_KEY_SERIES_ID, item.seriesId)
                                        // Search Info
                                        if (auto) {
                                            intent.putExtra(EXTRA_KEY_TYPE, QUERY_TYPE_SEARCH)
                                            intent.putExtra(EXTRA_KEY_SORTING, sortId)
                                            intent.putExtra(EXTRA_KEY_NOW_POSITION, position)
                                            intent.putExtra(EXTRA_KEY_KEYWORD, searchKeyword)
                                            intent.putExtra(EXTRA_KEY_GRADE, searchGrade)
                                            intent.putExtra(EXTRA_KEY_SUBJECT_ID, subjectId)
                                            Log.v(TAG, "subjectId => $subjectId")
                                        }
                                        startActivity(intent)
                                    }
                                }

                            } else {
                                Log.i(TAG, "VideoActivity In, From is true")
                                (this as Activity).apply {
                                    val intent = Intent(context, VideoActivity::class.java)
                                    val activity = (this as SearchResultActivity)
                                    val bottomPosition = activity.setBottomInfo()

                                    intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, item.videoId ?: item.id)
                                    intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)

                                    if (auto) {
                                        intent.putExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_SEARCH)
                                        intent.putExtra(Constants.EXTRA_KEY_SORTING, sortId)
                                        intent.putExtra(Constants.EXTRA_KEY_NOW_POSITION, position)
                                        intent.putExtra(Constants.EXTRA_KEY_KEYWORD, searchKeyword)
                                    }

                                    intent.putExtra(Constants.EXTRA_KEY_VIDEO_URL, bottomQuery[Constants.EXTRA_KEY_VIDEO_URL] as String)
                                    intent.putExtra(Constants.EXTRA_KEY_VIDEO_TITLE, bottomQuery[Constants.EXTRA_KEY_VIDEO_TITLE] as String)
                                    intent.putExtra(Constants.EXTRA_KEY_TEACHER_NAME, bottomQuery[Constants.EXTRA_KEY_TEACHER_NAME] as String)
                                    intent.putExtra(Constants.EXTRA_KEY_VIDEO_POSITION, bottomPosition)

                                    intent.putExtra(Constants.EXTRA_KEY_BOTTOM_VIDEO_ID, "${bottomQuery[Constants.EXTRA_KEY_VIDEO_ID]}")
                                    intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID, "${bottomQuery[Constants.EXTRA_KEY_BOTTOM_SERIES_ID]}")
                                    intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID, bottomQuery[Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID] as Int)
                                    intent.putExtra(Constants.EXTRA_KEY_BOTTOM_GRADE, bottomQuery[Constants.EXTRA_KEY_BOTTOM_GRADE] as String?)
                                    intent.putExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, bottomQuery[Constants.EXTRA_KEY_BOTTOM_SORTING] as Int)
                                    intent.putExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD, bottomQuery[Constants.EXTRA_KEY_BOTTOM_KEYWORD] as String?)
                                    intent.putExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE, bottomQuery[Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE] as Int)
                                    intent.putExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION, bottomQuery[Constants.EXTRA_KEY_BOTTOM_NOW_POSITION] as Int)

                                    Log.v(TAG, "EXTRA_KEY_BOTTOM_VIDEO_ID => ${bottomQuery[Constants.EXTRA_KEY_VIDEO_ID]}")
                                    Log.v(TAG, "EXTRA_KEY_BOTTOM_SERIES_ID => ${bottomQuery[Constants.EXTRA_KEY_BOTTOM_SERIES_ID]}")
                                    Log.v(TAG, "EXTRA_KEY_BOTTOM_SUBJECT_ID => ${bottomQuery[Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID]}")
                                    Log.v(TAG, "EXTRA_KEY_BOTTOM_GRADE => ${bottomQuery[Constants.EXTRA_KEY_BOTTOM_GRADE]}")
                                    Log.v(TAG, "EXTRA_KEY_BOTTOM_SORTING => ${bottomQuery[Constants.EXTRA_KEY_BOTTOM_SORTING]}")
                                    Log.v(TAG, "EXTRA_KEY_BOTTOM_KEYWORD => ${bottomQuery[Constants.EXTRA_KEY_BOTTOM_KEYWORD]}")
                                    Log.v(TAG, "EXTRA_KEY_BOTTOM_QUERY_TYPE => ${bottomQuery[Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE]}")
                                    Log.v(TAG, "EXTRA_KEY_BOTTOM_NOW_POSITION => ${bottomQuery[Constants.EXTRA_KEY_BOTTOM_NOW_POSITION]}")

                                    activity.backToVideoInAdapter()

                                    setResult(Activity.RESULT_OK, intent)
                                    finish()
                                }
                            }

                        }
                    }
                }
            }
        }
    }

    private class ItemViewHolder (private val binding : ItemSearchVideoBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoData, listener: View.OnClickListener){
            binding.apply {
                this.search = data
                itemView.setOnClickListener(listener)
            }
        }
    }

    private class LoadingViewHolder (private val binding : ItemLoadingBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(){ binding.apply {} }
    }

}