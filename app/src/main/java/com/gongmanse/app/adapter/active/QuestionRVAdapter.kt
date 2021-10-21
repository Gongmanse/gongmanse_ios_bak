package com.gongmanse.app.adapter.active

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.activities.CounselDetailActivity
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ItemLoadingBinding
import com.gongmanse.app.databinding.ItemQuestionBinding
import com.gongmanse.app.fragments.active.ActiveQuestionFragment
import com.gongmanse.app.model.CounselData
import com.gongmanse.app.utils.Constants
import okhttp3.ResponseBody
import org.jetbrains.anko.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class QuestionRVAdapter(private val context: ActiveQuestionFragment) : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        private val TAG = QuestionRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<CounselData> = ArrayList()
    private var sortId : Int? = null
    private var isChecked: Boolean = false

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == Constants.VIEW_TYPE_ITEM) {
            val binding = ItemQuestionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            ItemViewHolder(binding)
        } else {
            val binding = ItemLoadingBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            LoadingViewHolder(binding)
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemId(position: Int) = position.toLong()

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ItemViewHolder) {
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

    private fun populateItemRows(holder: ItemViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item
                , {
                    Log.d(TAG, "item removed => $position")
                    itemView.context.apply {
                        alert(message = "삭제 하시겠습니까?") {
                            noButton { it.dismiss() }
                            yesButton { removeItem(position) }
                        }.show()
                    }
                }
                , {
                    Log.e(TAG,"QNA ID => ${item.cu_id}")
                    itemView.context.apply{
                        startActivity(intentFor<CounselDetailActivity>(
                            Constants.EXTRA_KEY_COUNSEL to item
                        ).singleTop())
                    }
                }
            )
//            itemView.tag = item
        }
    }

    private fun removeItem(position: Int) {
        RetrofitClient.getService().removeCounsel(items[position].cu_id!!).enqueue(object: Callback<ResponseBody> {
            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                Log.d(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    response.body()?.apply {
                        Log.v(TAG, "onResponse => $this")
                        items.removeAt(position)
                        context.updateTotalNum(true)
                        notifyItemRemoved(position)
                        notifyItemRangeChanged(position, items.size)
                        if (items.size < 1) context.onRefresh()
                    }
                }
            }
        })
    }

    fun addSortId(sortId : Int?){
        this.sortId = sortId
    }

    fun addItems(newItems: List<CounselData>) {
        Log.d(TAG, "isChecked => $isChecked")
        for (item in newItems) {
            item.isRemove = isChecked
        }
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun addItem(newItem: CounselData) {
        Log.d(TAG, "isChecked => $isChecked")
        newItem.isRemove = true
        items.add(newItem)
        notifyItemInserted(items.size)
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    fun setRemoveMode() {
        isChecked = isChecked.not()
        Log.d(TAG, "setRemoveState(): isChecked => $isChecked")
        for (item in items) {
            item.isRemove = isChecked
        }
        notifyDataSetChanged()
    }

    fun setNormalMode() {
        isChecked = false
        Log.d(TAG, "setNormalMode(): isChecked => $isChecked")
        for (item in items) {
            item.isRemove = isChecked
        }
        notifyDataSetChanged()
    }

    fun addLoading() {
        val item = CounselData().apply { this.itemType = Constants.VIEW_TYPE_LOADING }
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

    private class ItemViewHolder (private val binding : ItemQuestionBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : CounselData, remove: View.OnClickListener, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                Log.e(TAG, "CounselData => $data")
                ivRemove.setOnClickListener(remove)
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