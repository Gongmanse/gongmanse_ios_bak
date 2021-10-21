package com.gongmanse.app.adapter.teacher

import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.*
import com.gongmanse.app.databinding.ItemVideoBinding
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoQuery
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.IsWIFIConnected
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop
import kotlin.properties.Delegates

class TeacherDetailRVAdapter() : RecyclerView.Adapter<TeacherDetailRVAdapter.ViewHolder> () {


    private val items: ArrayList<VideoData> = ArrayList()
    private var auto = false
    private var id by Delegates.notNull<Int>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
                DataBindingUtil.inflate(
                        LayoutInflater.from(parent.context),
                        R.layout.item_video,
                        parent,
                        false
                )
        )
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]

        holder.apply {
            bind(item, View.OnClickListener {
                val wifiState = IsWIFIConnected().check(holder.itemView.context)
                itemView.context.apply {
                    if (Preferences.token.isEmpty()) {
                        alert(title = null, message = getString(R.string.content_text_toast_login)) {
                            positiveButton(getString(R.string.content_button_positive)) {
                                it.dismiss()
                                startActivity(intentFor<LoginActivity>().singleTop())
                            }
                        }.show()
                    } else {
                        if (!item.id.isNullOrEmpty()) {
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
                                intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID , item.videoId ?: item.id)
                                intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)

                                if (auto) {
                                    intent.putExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_TEACHER)
                                    intent.putExtra(Constants.EXTRA_KEY_NOW_POSITION, position)
                                    intent.putExtra("isAutoPlay", auto)
                                }
//                                intent.putExtra("seriesId", item.seriesId)
//                                intent.putExtra("videoId", item.videoId ?: item.id)
//                                intent.putExtra("type", Constants.QUERY_TYPE_TEACHER)
//                                intent.putExtra("isAutoPlay", auto)
                                startActivity(intent)

                            }
                        } else Log.e("item id", "is Null")
                    }
                }
            })
        }
    }
    fun addId(id : Int){
        this.id = id
    }
    fun autoPlay(bool : Boolean){
        auto = bool
    }

    fun addItems(newItems: List<VideoData>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }


    class ViewHolder (private val binding : ItemVideoBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoData, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
            }
        }
    }

}