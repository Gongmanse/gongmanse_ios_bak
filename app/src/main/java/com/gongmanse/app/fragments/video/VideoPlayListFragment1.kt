package com.gongmanse.app.fragments.video

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.adapter.video.PlayListRVAdapter1
import com.gongmanse.app.api.video.VideoRepository
import com.gongmanse.app.databinding.FragmentVideoPlayList1Binding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.VideoQuery
import com.gongmanse.app.model.VideoViewModel
import com.gongmanse.app.model.VideoViewModelFactory
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.koin.android.ext.android.bind


class VideoPlayListFragment1 : Fragment() {
    private lateinit var binding: FragmentVideoPlayList1Binding
    private lateinit var mVideoViewModel: VideoViewModel
    private lateinit var mRecyclerAdapter: PlayListRVAdapter1
    private lateinit var scrollListener: EndlessRVScrollListener
    private val linearLayoutManager = LinearLayoutManager(context)
    private var isLoading = false
    private var isNext = true

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentVideoPlayList1Binding.inflate(inflater).apply {
            val mVideoVideoViewModelFactory = VideoViewModelFactory(VideoRepository())
            mVideoViewModel = ViewModelProvider(requireActivity(), mVideoVideoViewModelFactory).get(VideoViewModel::class.java)
            viewModel = mVideoViewModel
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        bindUI()
    }

    private fun bindUI() {
        binding.layoutEmpty.title = resources.getString(R.string.content_empty_play_list)
        binding.isEmpty = true
        setRVLayout()
        getViewModel()
    }

    private fun setRVLayout() {
        binding.recyclerView.apply {
            layoutManager = linearLayoutManager
            addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL))
            if (adapter == null) {
                mRecyclerAdapter = PlayListRVAdapter1(this@VideoPlayListFragment1)
                mRecyclerAdapter.setHasStableIds(true)
                adapter = mRecyclerAdapter
            }
        }

        // 스크롤 이벤트
        scrollListener = object: EndlessRVScrollListener(linearLayoutManager) {
            override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                Log.d(TAG, "scrollListener\noffset : $offset\ntotalItemsCount : $totalItemsCount")
                if (!isLoading && totalItemsCount % 20 == 0) {
                    isLoading = true
                    binding.recyclerView.post {
                        mRecyclerAdapter.addLoading()
                        mVideoViewModel.playListOffset.postValue(totalItemsCount)
                    }
                }
            }
        }

        binding.recyclerView.addOnScrollListener(scrollListener)
        // 스크롤 이벤트 초기화
        scrollListener.resetState()
    }

    private fun getViewModel() {
        mVideoViewModel.playList.observe(viewLifecycleOwner, Observer {
            Log.v(TAG, "playList => $it")
            Log.v(TAG, "playListSize => ${it?.data?.size}")

            // API 요청으로 포지션 조회 시 강의 리스트 포지션과 재생아이템 포지션이 상이하여 직접 비교하도록 수정
            it.data?.let { list ->
                Log.v(TAG, "getViewModel list check")
                for (i in list.indices) {
                    if (list[i].id == mVideoViewModel.videoId.value)  {
                        Log.e(TAG, "playList position : $i")
                        mVideoViewModel.playListNowPosition.value = i
                        break;
                    }
                }
            }

            mRecyclerAdapter.addItems(it?.data)
            binding.isEmpty = mRecyclerAdapter.itemCount == 0
            isLoading = false
            mVideoViewModel.playListNowPosition.value?.let { position ->
                CoroutineScope(Dispatchers.Main).launch {
                    Log.e(TAG,"position:$position")

                    binding.recyclerView.addOnScrollListener(scrollListener)
                    scrollListener.resetState()

                    if (isNext) {
                        Log.e(TAG,"isNext true position set")
                        if (binding.isEmpty == false) {
                            binding.totalCount = it?.totalNum
                            binding.nowPosition = position
                            Handler(Looper.getMainLooper()).postDelayed({

                                mRecyclerAdapter.selectedItem(position)
                                binding.recyclerView.smoothScrollToPosition(position)
                            }, 300L)
                        }
                        isNext = false
                    }
                }
            }
        })

        mVideoViewModel.playListOffset.observe(viewLifecycleOwner, Observer {
            Log.v(TAG, "offset => $it")
            Handler(Looper.getMainLooper()).postDelayed({
                Log.v(TAG, "isLoading : $isLoading")
                if (isLoading) {
                    mRecyclerAdapter.removeLoading()
                    mVideoViewModel.loadPlayList()
                }
            }, 1500L)
        })

        mVideoViewModel.hashTag.observe(viewLifecycleOwner, Observer {
            Log.v(TAG, "hashTag => $it")
            binding.hash = it
        })
    }

    fun nextVideo() {
        if (Preferences.token.isNotEmpty()) {
            mVideoViewModel.apply {
                val nowPosition = playListNowPosition.value ?: 0
                Log.v(TAG, "nextVideo: nowPosition => $nowPosition")
                mRecyclerAdapter.getItems().let {
                    Log.v(TAG, "nextVideo: size => ${it.size} VideoData => $it")
                    nowPosition.plus(1).let { position ->
                        if (it.size.minus(1) >= position) {
                            val newItem = it[position]
                            setVideo(newItem.videoId ?: newItem.id, newItem.seriesId, position)
                            isNext = true
                        } else {
                            Log.v(TAG, "nextVideo finish.")
                        }
                    }
                }
            }
        } else {
            (context as VideoActivity).showLoginToast()
        }
    }

    fun setVideo(videoId: String?, seriesId: String?, position: Int) {
        Log.v(TAG, "videoId => $videoId, position => $position")
        if (Preferences.token.isNotEmpty()) {
            CoroutineScope(Dispatchers.Main).launch {
                val beforePosition = mVideoViewModel.playListNowPosition.value ?: 0
                if (mRecyclerAdapter.itemCount > position) {
                    mRecyclerAdapter.selectedItem(position)
                    mRecyclerAdapter.unSelectedItem(beforePosition)
                }
                withContext(Dispatchers.IO) {
                    mVideoViewModel.videoId.postValue(videoId)
                    mVideoViewModel.seriesId.postValue(seriesId)
                    mVideoViewModel.playListNowPosition.postValue(position)
                }

                binding.nowPosition = position
                binding.recyclerView.smoothScrollToPosition(position)
            }
        } else {
            (context as VideoActivity).showLoginToast()
        }
    }

    fun initIsNext() {
        if (::mRecyclerAdapter.isInitialized) {
            Log.v(TAG, "mRecyclerAdapter is initialized")
            mRecyclerAdapter.clear()
        }
        if (::binding.isInitialized) {
            binding.isEmpty = true
        }
        isNext = true
        isLoading = false
    }

    fun clearAdapter() {
        if (::mRecyclerAdapter.isInitialized) {
            mRecyclerAdapter.clear()
        }
    }

    companion object {
        private val TAG = VideoPlayListFragment1::class.java.simpleName

        fun newInstance() = VideoPlayListFragment1().apply {
            arguments = bundleOf()
        }

    }

}