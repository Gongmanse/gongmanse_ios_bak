package com.gongmanse.app.adapter.video

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.SearchResultActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.databinding.ItemHashTagBinding
import com.gongmanse.app.utils.Constants

@Suppress("CAST_NEVER_SUCCEEDS")
class HashTagRVAdapter(private val context: Activity) : RecyclerView.Adapter<HashTagRVAdapter.ViewHolder> () {

    private val items: ArrayList<String> = ArrayList()
    private var videoId: String? = null
    private var videoURL: String? = null
    private var playerPosition : Long? = 0L
    private var teacherName : String? = ""
    private var videoTitle : String? = ""
    private var seriesId : String? = ""

    companion object {
        private const val REQUEST_CODE_SEARCH_VIEW = 3000
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_hash_tag,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            itemView.tag = item
            bind(item, View.OnClickListener {
                (context as VideoActivity).setSearchResultViewInfo()
                (itemView.context as Activity).apply {
                    val intent = Intent(context, SearchResultActivity::class.java)

                    Constants.apply {
                        Log.d("HashTagRVAdapter"," HashTagRVAdapter=> $videoId ")
                        intent.putExtra(EXTRA_KEY_KEYWORD , item.substring(1))
                        intent.putExtra(EXTRA_KEY_VIDEO_URL, videoURL)
                        intent.putExtra(EXTRA_KEY_VIDEO_POSITION, playerPosition)
                        intent.putExtra(EXTRA_KEY_VIDEO_TITLE, videoTitle)
                        intent.putExtra(EXTRA_KEY_TEACHER_NAME, teacherName)
                        intent.putExtra(EXTRA_KEY_VIDEO_ID, context.mVideoViewModel.videoId.value)
                        intent.putExtra(EXTRA_KEY_BOTTOM_SERIES_ID, context.mVideoViewModel.seriesId.value)
                        intent.putExtra(EXTRA_KEY_BOTTOM_SUBJECT_ID, context.mVideoViewModel.subjectId.value)
                        intent.putExtra(EXTRA_KEY_BOTTOM_GRADE, context.mVideoViewModel.grade.value)
                        intent.putExtra(EXTRA_KEY_BOTTOM_SORTING, context.mVideoViewModel.sorting.value)
                        intent.putExtra(EXTRA_KEY_BOTTOM_KEYWORD, context.mVideoViewModel.keyword.value)
                        intent.putExtra(EXTRA_KEY_BOTTOM_QUERY_TYPE, context.mVideoViewModel.playListType.value)
                        intent.putExtra(EXTRA_KEY_BOTTOM_NOW_POSITION, context.mVideoViewModel.playListNowPosition.value)
                    }
                    (context).moveSearchResultView(intent)
                }
            })
        }
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    fun addVideoInfo(video_id: String?, url: String?, position: Long? ,title : String?, name:String? , series_id : String?) {
        videoId = video_id
        videoURL = url
        playerPosition = position
        videoTitle = title
        teacherName = name
        seriesId = series_id
    }

    fun addItems(values: List<String>) {
        items.addAll(values)
        notifyDataSetChanged()
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    class ViewHolder (private val binding : ItemHashTagBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : String, listener: View.OnClickListener){
            binding.apply {
                this.tag = data
                itemView.setOnClickListener(listener)
            }
        }
    }

}