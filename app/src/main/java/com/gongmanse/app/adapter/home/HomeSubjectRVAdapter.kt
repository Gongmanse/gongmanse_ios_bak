package com.gongmanse.app.adapter.home


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
import com.gongmanse.app.databinding.ItemVideoBinding
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoQuery
import com.gongmanse.app.utils.*
import kotlinx.android.synthetic.main.item_video.view.*
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class HomeSubjectRVAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        const val REQUEST_CODE = 9001
    }

    private val items: ArrayList<VideoData> = ArrayList()
    private var auto = false
    private var type : Int? = null
    private var sortId : Int? = null
    private var totalItemNum : Int = 0
    private var getType = 0

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
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

    }

    private fun populateItemRows(holder: ViewHolder, position: Int) {
        val item = items[position]

        holder.apply {
            GBLog.d("RecyclerViewHolder", "setTag")
            itemView.tag = holder

            bind(item, View.OnClickListener{
                Log.d("클릭시 타입","$type")
                Log.d("클릭시 아이템","${item.videoId}")
                val wifiState = IsWIFIConnected().check(holder.itemView.context)
                itemView.context.apply {
                    if (Preferences.token.isEmpty()) {
                        alert(title = null, message = getString(R.string.content_text_toast_login)) {
                            positiveButton(getString(R.string.content_button_positive)) {
                                it.dismiss()
                                (holder.itemView.context as MainActivity).openDrawer()
                            }
                        }.show()
                    } else {
                        when (type) {
                            Constants.QUERY_TYPE_NOTE -> {
                                Log.d("클릭후 타입", "$type , $it")
                                when (it) {
                                    it.iv_quick_video ->{
                                        if (!Preferences.mobileData && !wifiState) {
                                            wifiAlert(holder)
                                        }else{
                                            val intent = Intent(this, VideoActivity::class.java)
                                            intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, item.videoId ?: item.id)
                                            intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)
                                            intent.putExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_NOTE)
                                            intent.putExtra(Constants.EXTRA_KEY_SORTING, sortId)
                                            startActivity(intent)
                                        }
                                    }
                                    else -> {
                                        (itemView.context as Activity).apply {
                                            val intent = Intent(
                                                itemView.context,
                                                VideoNoteActivity::class.java
                                            )
                                            intent.putExtra(Constants.EXTRA_KEY_ITEMS, items)
                                            intent.putExtra(Constants.EXTRA_KEY_TOTAL_NUM,totalItemNum)
                                            intent.putExtra(Constants.EXTRA_KEY_NOW_POSITION,position)
                                            intent.putExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_NOTE)
                                            intent.putExtra(Constants.EXTRA_KEY_TYPE2, getType)
                                            Log.d("노트보기" , "item.videoId => ${item.videoId} : item.id => ${item.id} , position => $position ")
                                            startActivityForResult(intent, REQUEST_CODE)
                                        }
                                    }
                                }
                            }
                            Constants.QUERY_TYPE_SERIES ->{
                                if (!Preferences.mobileData && !wifiState) {
                                    wifiAlert(holder)
                                }else{
                                    val grade = item.title?.substring(1,2)
                                    Log.d("grade" ,"$grade")
                                    startActivity(intentFor<SeriesListActivity>(
                                        Constants.REQUEST_KEY_SERIES_ID to item.seriesId,
                                        Constants.EXTRA_KEY_GRADE to grade,
                                        Constants.EXTRA_KEY_ITEM to item
                                    ).singleTop())
                                }
                            }
                            else ->{
                                if (!Preferences.mobileData && !wifiState) {
                                    wifiAlert(holder)
                                }else{
                                    val intent = Intent(this, VideoActivity::class.java)
                                    intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, item.videoId ?: item.id)
                                    intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)
                                    if (auto) {
                                        intent.putExtra(Constants.EXTRA_KEY_TYPE, type)
                                        intent.putExtra(Constants.EXTRA_KEY_SORTING, sortId)
                                        intent.putExtra(Constants.EXTRA_KEY_NOW_POSITION,position)
                                    }
                                    startActivity(intent)
                                }
                            }
                        }
                    }
                }
            })
        }
    }

    private fun wifiAlert(holder: ViewHolder){
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

    fun clear(){
        items.clear()
        notifyDataSetChanged()
    }

    fun addType(type : Int?){
        this.type = type
    }

    fun addSortId(sortId : Int?){
        this.sortId = sortId
    }

    fun autoPlay(bool : Boolean){
        auto = bool
    }

    fun addItems(newItems: List<VideoData>) {
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }
    fun addTotalAndType(total : Int , type:Int){
        totalItemNum = total
        getType = type
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

    private class ViewHolder (private val binding : ItemVideoBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoData, listener: View.OnClickListener){
            binding.apply {
                this.data = data
//                layoutItems.setOnClickListener(listener)
//                ivQuickVideo.setOnClickListener(listener)
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