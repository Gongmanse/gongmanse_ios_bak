//package com.gongmanse.app.feature.main.home
//
//
//import android.app.Activity
//import android.content.Intent
//import android.util.Log
//import android.view.LayoutInflater
//import android.view.View
//import android.view.ViewGroup
//import androidx.recyclerview.widget.RecyclerView
//import com.gongmanse.app.R
//import com.gongmanse.app.activities.MainActivity
//import com.gongmanse.app.activities.SeriesListActivity
//import com.gongmanse.app.activities.SettingActivity
//import com.gongmanse.app.activities.VideoNoteActivity
//import com.gongmanse.app.databinding.ItemLoadingBinding
//import com.gongmanse.app.databinding.ItemVideoBinding
//import com.gongmanse.app.databinding.ItemVideosBinding
//import com.gongmanse.app.model.Body
//import com.gongmanse.app.model.VideoData
//import com.gongmanse.app.model.VideoQuery
//import com.gongmanse.app.utils.Commons
//import com.gongmanse.app.utils.Constants
//import com.gongmanse.app.utils.IsWIFIConnected
//import com.gongmanse.app.utils.Preferences
//import kotlinx.android.synthetic.main.item_video.view.*
//import org.jetbrains.anko.alert
//import org.jetbrains.anko.intentFor
//import org.jetbrains.anko.singleTop
//
//class HomeSubjectRVAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder> () {
//
//    companion object {
//        const val REQUEST_CODE = 9001
//    }
//
//    private val items: ArrayList<Body> = ArrayList()
//    private var auto = false
//    private var type : Int? = null
//    private var sortId : Int? = null
//
//    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
//        return if (viewType == Constants.VIEW_TYPE_ITEM) {
//            val binding = ItemVideosBinding.inflate(LayoutInflater.from(parent.context), parent, false)
//            ViewHolder(binding)
//        } else {
//            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
//            LoadingViewHolder(binding)
//        }
//    }
//
//    override fun getItemCount(): Int = items.size
//
//    override fun getItemId(position: Int) = position.toLong()
//
//    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
//        if (holder is ViewHolder) {
//            populateItemRows(holder, position)
//        } else if (holder is LoadingViewHolder) {
//            showLoadingView(holder, position)
//        }
//    }
//
//    override fun getItemViewType(position: Int): Int {
//        return items[position].itemType
//    }
//
//    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {
//
//    }
//
//    private fun populateItemRows(holder: ViewHolder, position: Int) {
//        val item = items[position]
//
//        holder.apply {
//            bind(item, View.OnClickListener{
//
//            })
//        }
//    }
//
//    fun clear(){
//        items.clear()
//        notifyDataSetChanged()
//    }
//
//    fun addSortId(sortId : Int?){
//        this.sortId = sortId
//    }
//
//    fun autoPlay(bool : Boolean){
//        auto = bool
//    }
//
//    fun addItems(newItems: List<Body>) {
//        val position = items.size
//        items.addAll(newItems)
//        notifyItemRangeInserted(position, newItems.size)
//    }
//
//    fun addLoading() {
//        val item = Body(
//            1,null,null,null,null,null,
//            null,null,null,null,null,null,null,null
//        ).apply { this.itemType = Constants.VIEW_TYPE_LOADING }
//        items.add(item)
//        notifyItemInserted(items.size - 1)
//    }
//
//    fun removeLoading() {
//        val position = items.size - 1
//        if (items[position].itemType == Constants.VIEW_TYPE_LOADING) {
//            items.removeAt(position)
//            val scrollPosition = items.size
//            notifyItemRemoved(scrollPosition)
//        }
//    }
//
//    private class ViewHolder (private val binding : ItemVideosBinding) : RecyclerView.ViewHolder(binding.root){
//        fun bind(data : Body, listener: View.OnClickListener){
//            binding.apply {
//                this.data = data
//                layoutItems.setOnClickListener(listener)
//                ivQuickVideo.setOnClickListener(listener)
//            }
//        }
//    }
//
//    private class LoadingViewHolder (private val binding : ItemLoadingBinding) : RecyclerView.ViewHolder(binding.root){
//        fun bind(){
//            binding.apply {
//
//            }
//        }
//    }
//}