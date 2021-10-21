package com.gongmanse.app.adapter.search

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ItemSearchRecentBinding
import com.gongmanse.app.listeners.OnSearchKeywordListener
import com.gongmanse.app.model.SearchRecentListData
import com.gongmanse.app.utils.Preferences
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class SearchRecentRVAdapter(private val listener: OnSearchKeywordListener) :
    RecyclerView.Adapter<SearchRecentRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = SearchRecentRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<SearchRecentListData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_search_recent,
                parent,
                false
            )
        )
    }

    fun addItems(newItems: List<SearchRecentListData>) {
        Log.e(TAG, "newItems => $newItems")
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
    }

    fun clear() {
        items.clear()
        notifyDataSetChanged()
    }

    private fun clearItem(position: Int) {
        Log.e(TAG, "clearItem ::")
        items.removeAt(position) // 아이템 삭제
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        Log.d(TAG, "item => $item / $position")
        holder.apply {
            bind(item, {
                clearItem(position)
                deleteRecentKeyword(Preferences.token, item.id.toInt())
            },
                {
                    listener.onSearchKeyword(item.keyword)
                })
        }
    }

    inner class ViewHolder(private val binding: ItemSearchRecentBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(
            data: SearchRecentListData,
            listenerDel: View.OnClickListener,
            listenerKeyword: View.OnClickListener
        ) {
            binding.apply {
                this.serach = data
                this.ivRecentKeywordDelete.setOnClickListener(listenerDel)
                this.tvSearch.setOnClickListener(listenerKeyword)
            }
        }
    }

    private fun deleteRecentKeyword(token: String, keyword_id: Int) {
        Log.d(TAG, "deleteRecentKeyword() \n Token => $token \n KeywordID => $keyword_id")
        RetrofitClient.getService().deleteRecentKeyword(token, keyword_id)
            .enqueue(object : Callback<Void> {
                override fun onFailure(call: Call<Void>, t: Throwable) {
                    Log.e(TAG, "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(
                    call: Call<Void>,
                    response: Response<Void>
                ) {
                    Log.d(TAG, "onResponse => ${response.body()}")
                    if (!response.isSuccessful) Log.e(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                    if (response.isSuccessful) {
                        Log.d(TAG, "response is Successful")
                        response.body()?.apply {
                            Log.i(TAG, "onResponse Body => ${response.body()}")
                        }
                    }
                }
            })
    }

}