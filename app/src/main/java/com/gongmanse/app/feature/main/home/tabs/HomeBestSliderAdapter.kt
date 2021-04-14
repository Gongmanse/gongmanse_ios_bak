package com.gongmanse.app.feature.main.home.tabs

import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import com.smarteist.autoimageslider.SliderViewAdapter
import com.gongmanse.app.data.model.video.Body
import com.gongmanse.app.databinding.ItemBannerViewBinding


class HomeBestSliderAdapter(private val context: Context): SliderViewAdapter<HomeBestSliderAdapter.SliderAdapterVH>() {

    private val items: ArrayList<Body> = ArrayList()

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
//        val query = VideoQuery(
//            videoId = item.id!!.toInt()
//            , position = position
//        )
//        holder?.apply {
//            bind(item, View.OnClickListener {
//                val wifiState = IsWIFIConnected().check(itemView.context)
//                itemView.context.apply {
//                    if (Preferences.token.isEmpty()) {
//                        alert(title = null, message = "로그인 후 이용 해주세요") {
//                            positiveButton("확인") {
//                                it.dismiss()
//                                (itemView.context as MainActivity).openDrawer()
//                            }
//                        }.show()
//                    } else {
//                        if (item.seriesCount == 0) {
//                            if (!Preferences.mobileData && !wifiState) {
//                                alert(
//                                    title = null,
//                                    message = " WIFI 를 연결하거나, 설정에서 모바일 데이터 사용을 허용해주세요"
//                                ) {
//                                    positiveButton("설정") {
//                                        it.dismiss()
//                                        startActivity(intentFor<SettingActivity>().singleTop())
//                                    }
//                                    negativeButton("닫기") {
//                                        it.dismiss()
//                                    }
//                                }.show()
//                            } else {
//                                Commons.goVideoView(itemView.context, query)
//                            }
//                        }
//                    }
//                    if (Preferences.token.isEmpty()) {
//                        val query = VideoQuery(
//                            videoId = item.id!!.toInt()
//                            , position = position
//                            , queryType = Constants.QUERY_TYPE_BEST
//                        )
//                        Commons.goVideoView(itemView.context, query)
//                    } else {
//                        val query = VideoQuery(
//                            videoId = item.id!!.toInt()
//                            , position = position
//                        )
//                        if (item.seriesCount == 0) {
//                            if (!Preferences.mobileData && !wifiState) {
//                                alert(
//                                    title = null,
//                                    message = " WIFI 를 연결하거나, 설정에서 모바일 데이터 사용을 허용해주세요"
//                                ) {
//                                    positiveButton("설정") {
//                                        it.dismiss()
//                                        startActivity(intentFor<SettingActivity>().singleTop())
//                                    }
//                                    negativeButton("닫기") {
//                                        it.dismiss()
//                                    }
//                                }.show()
//                            } else {
//                                Commons.goVideoView(itemView.context, query)
//                            }
//                        }
//                    }
//                }
//            })
//        }
    }

//    fun clear(){
//        items.clear()
//        notifyDataSetChanged()
//    }
    override fun getCount(): Int {
        return items.size
    }
//    fun addItems(newItems: List<VideoData>) {
//        items.clear()
//        items.addAll(newItems)
//        notifyDataSetChanged()
//    }


    inner class SliderAdapterVH(private val binding : ItemBannerViewBinding): SliderViewAdapter.ViewHolder(binding.root) {

//        fun bind(data: VideoData,listener: View.OnClickListener) {
//            binding.apply {
//                this.data = data
//                itemView.setOnClickListener(listener)
//            }
//        }
    }



}