package com.gongmanse.app.adapter.progress

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.*
import com.gongmanse.app.databinding.ItemProgressDetailBinding
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.GBLog
import com.gongmanse.app.utils.IsWIFIConnected
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class ProgressDetailRVAdapter(private val context: Activity) : RecyclerView.Adapter<ProgressDetailRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = ProgressDetailRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<VideoData> = ArrayList()
    private var auto = false

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_progress_detail, parent, false
            )
        )
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    fun addItems(newItems: List<VideoData>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun autoPlay(boolean: Boolean) {
        auto = boolean
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            GBLog.d("RecyclerViewHolder", "setTag")
            itemView.tag = holder

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
                                this@ProgressDetailRVAdapter.context.apply {
                                    val intent = Intent(this, LoginActivity::class.java)
                                    val activity = (this as ProgressDetailPageActivity)
                                    activity.moveLoginActivity(intent)
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
                            itemView.context.apply {
                                val intent = Intent(this, VideoActivity::class.java)
                                Constants.apply {
                                    intent.putExtra(EXTRA_KEY_VIDEO_ID, item.videoId ?: item.id)
                                    intent.putExtra(EXTRA_KEY_SERIES_ID, item.seriesId)
                                    Log.v(TAG, "SERIES ID: ${item.seriesId}")
                                    if (auto) {
                                        intent.putExtra(EXTRA_KEY_JINDO_ID, item.jindoId)
                                        intent.putExtra(EXTRA_KEY_TYPE, QUERY_TYPE_PROGRESS)
                                        intent.putExtra(EXTRA_KEY_NOW_POSITION, position)
                                        Log.v(TAG, "position => $position")
                                    }
                                    startActivity(intent)
                                }

                            }
                        }
                    }
                }
            }
        }
    }

    inner class ViewHolder(private val binding: ItemProgressDetailBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: VideoData, listener: View.OnClickListener) {
            binding.apply {
                this.video = data
                itemView.setOnClickListener(listener)
            }
        }

    }
}