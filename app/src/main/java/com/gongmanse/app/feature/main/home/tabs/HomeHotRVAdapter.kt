package com.gongmanse.app.feature.main.home.tabs

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.data.model.video.Body
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemVideoBinding
import com.gongmanse.app.utils.Constants


class HomeHotRVAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    private val items: ArrayList<Body> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.Endless.VIEW_TYPE_ITEM) {
            val binding = ItemVideoBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int) = position.toLong()

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ViewHolder) {
            populateItemRows(holder, position)
        } else if (holder is LoadingViewHolder) {
            showLoadingView(holder, position)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return items[position].itemType
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {
        holder.apply {
            bind()
        }
    }

    private fun populateItemRows(holder: ViewHolder, position: Int) {
//        val item = items[position]
//        Log.e("item.id is null?", "item.id => ${item.id}")
//        val query = VideoQuery(
//            videoId = item.id!!.toInt()
//            ,position = position
//        )
//        holder.apply {
//            bind(item, View.OnClickListener {
//                val wifiState = IsWIFIConnected().check(holder.itemView.context)
//                itemView.context.apply {
//                    if (Preferences.token.isEmpty()) {
//                        alert(title = null, message = getString(R.string.content_text_toast_login)) {
//                            positiveButton(getString(R.string.content_button_positive)) {
//                                it.dismiss()
//                                (holder.itemView.context as MainActivity).openDrawer()
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
//                                Commons.goVideoView(itemView.context,query)
//                            }
//                        }
//                    }
//                }
//            })
//        }
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

//    fun addItems(newItems: List<VideoData>) {
//        val position = items.size
//        items.addAll(newItems)
//        notifyItemRangeInserted(position, newItems.size)
//    }
//
//    fun addLoading() {
//        val item = VideoData().apply { this.itemType = Constants.Endless.VIEW_TYPE_LOADING }
//        items.add(item)
//        notifyDataSetChanged()
////        notifyItemInserted(items.size - 1)
//    }

    fun removeLoading() {
        val position = items.size - 1
        if (items[position].itemType == Constants.Endless.VIEW_TYPE_LOADING) {
            items.removeAt(position)
            val scrollPosition = items.size
            notifyItemRemoved(scrollPosition)
        }
    }

    private class ViewHolder (private val binding : ItemVideoBinding) : RecyclerView.ViewHolder(binding.root){
//        fun bind(data : VideoData, listener: View.OnClickListener){
//            binding.apply {
//                this.data = data
//                itemView.setOnClickListener(listener)
//            }
//        }
    }

    private class LoadingViewHolder (private val binding : ItemLoadingBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(){
            binding.apply {

            }
        }
    }

}