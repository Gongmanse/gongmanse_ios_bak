package com.gongmanse.app.adapter.home

import android.content.Context
import android.content.Intent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.smarteist.autoimageslider.SliderViewAdapter
import com.gongmanse.app.activities.MainActivity
import com.gongmanse.app.activities.SettingActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.databinding.ItemBannerViewBinding
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoQuery
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.IsWIFIConnected
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop


class HomeBestSliderAdapter(private val context: Context): SliderViewAdapter<HomeBestSliderAdapter.SliderAdapterVH>() {

    private val items: ArrayList<VideoData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup?): SliderAdapterVH {
        val binding = ItemBannerViewBinding.inflate(
            LayoutInflater.from(context),
            parent,
            false
        )
//        loadBanner()
        return SliderAdapterVH(binding)
    }

    override fun onBindViewHolder(holder: SliderAdapterVH?, position: Int) {
        val item = items[position]
        holder?.apply {
            bind(item, View.OnClickListener {
                val wifiState = IsWIFIConnected().check(itemView.context)
                itemView.context.apply {
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
                    }else{
                        item.id?.let {
                            val intent = Intent(this, VideoActivity::class.java)
                            intent.putExtra(Constants.EXTRA_KEY_SERIES_ID,item.seriesId)
                            intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, it)
                            intent.putExtra(Constants.EXTRA_KEY_TYPE,Constants.QUERY_TYPE_BEST)
                            startActivity(intent)
                        }
                    }
                }
            })
        }
    }

    fun clear(){
        items.clear()
        notifyDataSetChanged()
    }
    override fun getCount(): Int {
        return items.size
    }
    fun addItems(newItems: List<VideoData>) {
        items.clear()
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    inner class SliderAdapterVH(private val binding : ItemBannerViewBinding): SliderViewAdapter.ViewHolder(binding.root) {

        fun bind(data: VideoData,listener: View.OnClickListener) {
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
            }
        }
    }
}