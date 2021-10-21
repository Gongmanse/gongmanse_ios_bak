package com.gongmanse.app.adapter.counsel


import android.net.Uri
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.activities.CounselCreateActivity
import com.gongmanse.app.databinding.ItemCounselMediaImageBinding
import com.gongmanse.app.databinding.ItemCounselMediaVideoBinding
import com.gongmanse.app.utils.Constants
import org.jetbrains.anko.toast


class CounselCreateRVAdapter(private val mActivity : CounselCreateActivity) : RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    private val items: ArrayList<Uri> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        Log.d("viewType 들어온것" , "$viewType")
        when (viewType) {
            Constants.COUNSEL_TYPE_IMAGE -> {
                val binding = ItemCounselMediaImageBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return ImageHolder(binding)
            }
            else -> {
                val binding = ItemCounselMediaVideoBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return VideoHolder(binding)
            }
        }
    }

    private fun deleteItem(position : Int){
        items.removeAt(position)
        notifyDataSetChanged()
    }

    fun addItems(newItems: Uri) {
        items.add(newItems)
        Log.d("item" , "ImageHolder: ${newItems}")
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val item = items[position]
        when(holder) {
            is ImageHolder ->{
                holder.apply {
                    bind(item.toString(),View.OnClickListener {
                        try{
                            deleteItem(position)
                            mActivity.deleteFile(position)
                            mActivity.indicatorControl()
                        }catch (i : IndexOutOfBoundsException){
                            Toast.makeText(itemView.context.applicationContext, "잠시후 다시 시도해 주세요", Toast.LENGTH_SHORT).show()
                        }
                    })
                }
            }
            is VideoHolder ->{
                holder.apply {
                    bind(item.toString(), View.OnClickListener {
                        try{
                            deleteItem(position)
                            mActivity.deleteFile(position)
                            mActivity.indicatorControl()
                        }catch (i : IndexOutOfBoundsException){
                            Toast.makeText(itemView.context.applicationContext, "잠시후 다시 시도해 주세요", Toast.LENGTH_SHORT).show()
                        }
                    })
                }
            }
        }
    }
    override fun getItemViewType(position: Int): Int {
        items[position].let {
            return if(it.toString().endsWith(".mp4")){
                Log.d("video","${items[position]}")
                Constants.COUNSEL_TYPE_VIDEO
            }else{
                Log.d("imageType","${items[position]}")
                Constants.COUNSEL_TYPE_IMAGE
            }
        }
    }

    class VideoHolder(private val binding: ItemCounselMediaVideoBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: String?,listener: View.OnClickListener) {
            Log.d("item" , "VideoHolder: ${item}")
            binding.apply {
                this.data = item
                this.ivDelete.setOnClickListener(listener)
            }
        }
    }

    class ImageHolder(private val binding: ItemCounselMediaImageBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: String?,listener: View.OnClickListener) {
            Log.d("item" , "ImageHolder: ${item}")
            binding.apply {
                this.data = item
                this.ivDelete.setOnClickListener(listener)
            }
        }
    }
}