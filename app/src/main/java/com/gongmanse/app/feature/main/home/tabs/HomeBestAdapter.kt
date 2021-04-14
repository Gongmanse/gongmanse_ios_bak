package com.gongmanse.app.feature.main.home.tabs


import android.util.Log
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.data.model.video.Body
import com.gongmanse.app.databinding.*
import com.gongmanse.app.utils.Constants

class HomeBestAdapter :  RecyclerView.Adapter<RecyclerView.ViewHolder> () {

    companion object {
        private val TAG = HomeBestAdapter::class.java.simpleName
    }

    private val items: ArrayList<Body> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        when (viewType) {
            Constants.BestValue.BANNER_TYPE -> {
                val binding = ItemBannerBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return BannerViewHolder(binding)
            }
            Constants.BestValue.TITLE_TYPE -> {
                val binding = ItemBestTitleBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                return TitleViewHolder(binding)
            }
            Constants.BestValue.LOADING_TYPE -> {
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

//    override fun getItemViewType(position: Int): Int {
//        items[position].viewType.let {
//            return when(items[position].viewType){
//                Constants.BestValue.BANNER_TYPE.toString() -> Constants.BestValue.BANNER_TYPE
//                Constants.BestValue.TITLE_TYPE.toString() -> Constants.BestValue.TITLE_TYPE
//                Constants.BestValue.RV_TYPE.toString() -> Constants.BestValue.RV_TYPE
//                Constants.BestValue.LOADING_TYPE.toString() -> Constants.BestValue.LOADING_TYPE
//                else -> Constants.BestValue.RV_TYPE
//            }
//        }
//    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        Log.d("홀더 확인","$holder")
        val item = items[position]
        when(holder) {
            is LoadingViewHolder -> {
                showLoadingView(holder, position)
            }
            is BannerViewHolder -> {
                holder.apply {
//                    bind(items)
                }
            }
            is TitleViewHolder -> {
                holder.apply {
                    bind(Constants.BestValue.TITLE_VALUE)
                }
            }
            is RecyclerViewHolder -> {
                Log.d("진입 홀더 확인","$holder")
                holder.apply {
//                    bind(item, View.OnClickListener {
//                        val wifiState = IsWIFIConnected().check(holder.itemView.context)
//                        itemView.context.apply {
//                            Log.d("입구","어댑터 클릭")
//                            if (Preferences.token.isEmpty()) {
//                                Log.d("if 토큰없음","어댑터 클릭")
//                                val query = VideoQuery(
//                                      videoId = item.id!!.toInt()
//                                    , position = position
//                                    , queryType = Constants.QUERY_TYPE_BEST
//                                )
//                                Commons.goVideoView(itemView.context, query)
//                            } else {
//                                Log.d("else1","어댑터 클릭")
//                                val query = VideoQuery(
//                                      videoId = item.id!!.toInt()
//                                    , position = position
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
//                            }
//                        }
//                    })
                }
            }
        }
    }

    private fun showLoadingView(holder: LoadingViewHolder, position: Int) {

    }

//    fun addItems(newItems: List<VideoData>) {
//        val position = items.size
//        items.addAll(newItems)
//        notifyItemRangeInserted(position, newItems.size)
////        notifyDataSetChanged()
//    }
//
//    fun clear(){
//        items.clear()
//        notifyDataSetChanged()
//    }
//
//    fun addLoading() {
//        val item = VideoData().apply { this.viewType = Constants.BestValue.LOADING_TYPE.toString() }
//        items.add(item)
//        notifyItemInserted(items.size - 1)
//    }

    fun removeLoading() {
//        val position = items.size - 1
//        if (items[position].viewType == Constants.BestValue.LOADING_TYPE.toString()) {
//            items.removeAt(position)
//            val scrollPosition = items.size
//            notifyItemRemoved(scrollPosition)
//        }
    }

    private class BannerViewHolder(private val binding: ItemBannerBinding) : RecyclerView.ViewHolder(binding.root){
        val mAdapter = HomeBestSliderAdapter(binding.root.context)

//        fun bind(data : List<VideoData>){
//            data.let {
//                loadBanner()
////                mAdapter.addItems(data)
//                binding.sliderView.apply {
//                    setSliderAdapter(mAdapter)
//                    setIndicatorAnimation(IndicatorAnimationType.SWAP)
//                    setSliderTransformAnimation(SliderAnimations.SIMPLETRANSFORMATION)
//                    setSliderAnimationDuration(600)
//                    setIndicatorAnimationDuration(600)
//                    scrollTimeInSec =3
//                    startAutoCycle()
//                }
//            }
//        }
//        private fun loadBanner() {
//            RetrofitClient.getService().getBannerList(Constants.BestValue.BANNER_COUNT).enqueue(object :
//                Callback<VideoList> {
//                override fun onFailure(call: Call<VideoList>, t: Throwable) {
//                    Log.e("Retrofit : onFailure ", "Failed API call with call : $call\nexception : $t")
//                }
//
//                override fun onResponse(
//                    call: Call<VideoList>,
//                    response: Response<VideoList>
//                ) {
//                    if (!response.isSuccessful) Log.d(
//                        "Retrofit :responseFail",
//                        "Failed API code : ${response.code()}\n message : ${response.message()}"
//                    )
//                    if (response.isSuccessful) {
//                        Log.d("Retrofit : isSuccessful", "onResponse => $this")
//                        Log.i("Retrofit : isSuccessful", "onResponse Body => ${response.body()}")
//                        response.body()?.apply {
//                            this.data.let {
//                                mAdapter.addItems(it as List<VideoData>)
//                            }
//                        }
//                    }
//                }
//            })
//        }
    }

    private class TitleViewHolder(private val binding: ItemBestTitleBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : String){
            binding.apply {
                this.data = data
            }
        }
    }


    private class RecyclerViewHolder (private val binding : ItemVideoBinding) : RecyclerView.ViewHolder(binding.root){
//        fun bind(data : VideoData, listener: View.OnClickListener){
//            Log.d("홀더 확인","홀더 진입")
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