package com.gongmanse.app.adapter.home


import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.smarteist.autoimageslider.IndicatorView.animation.type.IndicatorAnimationType
import com.smarteist.autoimageslider.SliderAnimations
import com.gongmanse.app.activities.SettingActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.adapter.active.RecentVideoRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.*
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.model.VideoList
import com.gongmanse.app.model.VideoQuery
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.IsWIFIConnected
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class HomeBestAdapter1 :  RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        private val TAG = HomeBestAdapter1::class.java.simpleName
    }

    private val items: ArrayList<VideoData> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        when (viewType) {
            Constants.BEST_BANNER_TYPE -> {
                val binding = ItemBannerBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return BannerViewHolder(binding)
            }
            Constants.BEST_TITLE_TYPE -> {
                val binding = ItemBestTitleBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return TitleViewHolder(binding)
            }
            Constants.BEST_LOADING_TYPE -> {
                val binding = ItemLoadingBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return LoadingViewHolder(binding)
            }
            else -> {
                val binding = ItemVideoBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return RecyclerViewHolder(binding)
            }
        }
    }

    override fun getItemCount(): Int = items.size

    override fun getItemViewType(position: Int): Int {
        items[position].viewType.let {
            return when(items[position].viewType){
                Constants.BEST_BANNER_TYPE.toString() -> Constants.BEST_BANNER_TYPE
                Constants.BEST_TITLE_TYPE.toString() -> Constants.BEST_TITLE_TYPE
                Constants.BEST_RV_TYPE.toString() -> Constants.BEST_RV_TYPE
                Constants.BEST_LOADING_TYPE.toString() -> Constants.BEST_LOADING_TYPE
                else -> Constants.BEST_RV_TYPE
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        Log.d("홀더 확인","$holder")
        val item = items[position]
        when(holder) {
            is LoadingViewHolder -> {
                showLoadingView(holder, position)
            }
            is BannerViewHolder -> {
                holder.apply {
                    bind(items)
                }
            }
            is TitleViewHolder -> {
                holder.apply {
                    bind(Constants.BEST_TITLE_VALUE)
                }
            }
            is RecyclerViewHolder -> {
                Log.d("진입 홀더 확인","$holder")
                holder.apply {
                    bind(item, View.OnClickListener {
                        val wifiState = IsWIFIConnected().check(holder.itemView.context)
                        itemView.context.apply {
                            Log.d("입구","어댑터 클릭 ${item.id}")
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
                            }else {
                                if (Preferences.token.isEmpty()) {
                                    item.id?.let {
                                        val intent = Intent(this, VideoActivity::class.java)
                                        intent.putExtra(Constants.EXTRA_KEY_SERIES_ID,item.seriesId)
                                        intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, it)
                                        intent.putExtra(Constants.EXTRA_KEY_TYPE,Constants.QUERY_TYPE_BEST)
//                                        intent.putExtra(Constants.EXTRA_KEY_NOW_POSITION,position)
                                        startActivity(intent)
                                    }
//                                Log.d("if 토큰없음","어댑터 클릭")
//                                val query = VideoQuery(
//                                      videoId = item.id!!.toInt()
//                                    , position = position
//                                    , queryType = Constants.QUERY_TYPE_BEST
//                                )
//                                Commons.goVideoView(itemView.context, query)
                                } else {
                                    item.id?.let {
                                        val intent = Intent(this, VideoActivity::class.java)
                                        intent.putExtra(Constants.EXTRA_KEY_SERIES_ID,item.seriesId)
                                        intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, it)
//                                        intent.putExtra(Constants.EXTRA_KEY_NOW_POSITION,position)
                                        intent.putExtra(Constants.EXTRA_KEY_TYPE,Constants.QUERY_TYPE_BEST)
                                        startActivity(intent)
                                    }
                                }

//                                Log.d("else1","어댑터 클릭")
//                                val query = VideoQuery(
//                                      videoId = item.id!!.toInt()
//                                    , position = position
//                                    , queryType = Constants.QUERY_TYPE_BEST
//                                )
//                                if (item.seriesCount == 0) {
//                                    if (!Preferences.mobileData && !wifiState) {
//                                        alert(
//                                            title = null,
//                                            message = " WIFI 를 연결하거나, 설정에서 모바일 데이터 사용을 허용해주세요"
//                                        ) {
//                                            positiveButton("설정") {
//                                                it.dismiss()
//                                                startActivity(intentFor<SettingActivity>().singleTop())
//                                            }
//                                            negativeButton("닫기") {
//                                                it.dismiss()
//                                            }
//                                        }.show()
//                                    } else {
//                                        Log.d("else2","어댑터 클릭")
//                                        Commons.goVideoView(itemView.context, query)
//                                    }
//                                }
                            }
                        }
                    })
                }
            }
        }
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {

    }

    fun addItems(newItems: List<VideoData>) {
        val position = items.size
        items.addAll(newItems)
        notifyItemRangeInserted(position, newItems.size)
//        notifyDataSetChanged()
    }

    fun clear(){
        items.clear()
        notifyDataSetChanged()
    }

    fun addLoading() {
        val item = VideoData().apply { this.viewType = Constants.BEST_LOADING_TYPE.toString() }
        items.add(item)
        notifyItemInserted(items.size - 1)
    }

    fun removeLoading() {
        val position = items.size - 1
        if (items[position].viewType == Constants.BEST_LOADING_TYPE.toString()) {
            items.removeAt(position)
            val scrollPosition = items.size
            notifyItemRemoved(scrollPosition)
        }
    }

    private class BannerViewHolder(private val binding: ItemBannerBinding) : RecyclerView.ViewHolder(binding.root){
        val mAdapter = HomeBestSliderAdapter(binding.root.context)

        fun bind(data : List<VideoData>){
            data.let {
                loadBanner()
//                mAdapter.addItems(data)`
                binding.sliderView.apply {
                    setSliderAdapter(mAdapter)
                    setIndicatorAnimation(IndicatorAnimationType.SWAP)
                    setSliderTransformAnimation(SliderAnimations.SIMPLETRANSFORMATION)
                    setSliderAnimationDuration(600)
                    setIndicatorAnimationDuration(600)
                    scrollTimeInSec =3
                    startAutoCycle()
                }
            }
        }
        private fun loadBanner() {
            RetrofitClient.getService().getBannerList(Constants.BEST_BANNER_COUNT).enqueue(object :
                Callback<VideoList> {
                override fun onFailure(call: Call<VideoList>, t: Throwable) {
                    Log.e("Retrofit : onFailure ", "Failed API call with call : $call\nexception : $t")
                }

                override fun onResponse(
                    call: Call<VideoList>,
                    response: Response<VideoList>
                ) {
                    if (!response.isSuccessful) Log.d(
                        "Retrofit :responseFail",
                        "Failed API code : ${response.code()}\n message : ${response.message()}"
                    )
                    if (response.isSuccessful) {
                        Log.d("Retrofit : isSuccessful", "onResponse => $this")
                        Log.i("Retrofit : isSuccessful", "onResponse Body => ${response.body()}")
                        response.body()?.apply {
                            this.data.let {
                                mAdapter.addItems(it as List<VideoData>)
                            }
                        }
                    }
                }
            })
        }
    }

    private class TitleViewHolder(private val binding: ItemBestTitleBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : String){
            binding.apply {
                this.data = data
            }
        }
    }


    private class RecyclerViewHolder (private val binding : ItemVideoBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoData, listener: View.OnClickListener){
            Log.d("홀더 확인","홀더 진입")
            binding.apply {
                this.data = data
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