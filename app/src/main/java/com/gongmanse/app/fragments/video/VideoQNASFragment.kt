package com.gongmanse.app.fragments.video


import android.content.Context
import android.graphics.Rect
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.gongmanse.app.R
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.adapter.video.QNAContentsRVAdapter
import com.gongmanse.app.api.video.VideoRepository
import com.gongmanse.app.databinding.FragmentVideoQnasBinding
import com.gongmanse.app.listeners.EndlessRVScrollListener
import com.gongmanse.app.model.VideoViewModel
import com.gongmanse.app.model.VideoViewModelFactory
import com.gongmanse.app.utils.AndroidBug5497Workaround
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import org.jetbrains.anko.sdk27.coroutines.onFocusChange

class VideoQNASFragment : Fragment() {

    private lateinit var binding: FragmentVideoQnasBinding
    private lateinit var mAdapter: QNAContentsRVAdapter
    private lateinit var imm: InputMethodManager
    private lateinit var mVideoViewModel: VideoViewModel
    private lateinit var scrollListener: EndlessRVScrollListener

    private var isLoading = false
    private val linearLayoutManager = LinearLayoutManager(context)

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        activity?.let { AndroidBug5497Workaround(it).addListener() }
        binding = FragmentVideoQnasBinding.inflate(inflater).apply {
            val mVideoVideoViewModelFactory = VideoViewModelFactory(VideoRepository())
            mVideoViewModel = ViewModelProvider(requireActivity(), mVideoVideoViewModelFactory).get(VideoViewModel::class.java)
            viewModel = mVideoViewModel
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initView()
    }

    override fun onDetach() {
        activity?.let { AndroidBug5497Workaround(it).removeListener() }
        super.onDetach()
    }

    private val onRefresh = SwipeRefreshLayout.OnRefreshListener {
        mAdapter.clear()
        isLoading = true
        binding.recyclerView.post {
            mAdapter.addLoading()
        }
        mVideoViewModel.offsetQNA.value = Constants.OFFSET_DEFAULT
        binding.refreshLayout.isRefreshing = false
    }

    private fun initView() {
        Log.e(TAG,"initView()")
        initRVLayout()
        setupData()
        setEditText()
        binding.apply {
            layoutEmpty.title = resources.getString(R.string.content_empty_qna_contents)
            isEmpty = true
            refreshLayout.setOnRefreshListener(onRefresh)
            imm = context?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        }
    }

    fun hideSoftKeyboard() {
        imm.hideSoftInputFromWindow(binding.etQuestion.windowToken, 0)
    }

    private fun setEditText(){
        binding.apply {
            (context as VideoActivity).apply {
                etQuestion.setOnClickListener {
                    onSlideClose()
                }
                etQuestion.onFocusChange { v, hasFocus ->
                    onSlideClose()
                }
            }

            // 가로모드 [전송] 버튼 action
            etQuestion.setOnEditorActionListener { v, actionId, event ->
                return@setOnEditorActionListener when (actionId) {
                    EditorInfo.IME_ACTION_SEND -> {
                        mVideoViewModel.addQNAComment()
                        true
                    }
                    else -> false
                }
            }
        }

    }

    private fun setupData() {
        mVideoViewModel.apply {
            currentQNAData.observe(viewLifecycleOwner, Observer { data ->
                Log.v(TAG,"currentQNAData Data:$data")
                mAdapter.addItems(data)
                binding.apply {
                    isEmpty = mAdapter.itemCount == 0
                    binding.apply {
                        if (isEmpty == false) {
                            Log.e(TAG,"isEmpty => $isEmpty")
                            Handler(Looper.getMainLooper()).postDelayed({
                                nestedScrollView.let { v ->
                                    v.smoothScrollBy(0, v.getChildAt(v.childCount - 1).measuredHeight - v.measuredHeight)
                                }
                            }, Constants.BOTTOM_MOVE_DELAY)
                        }
                    }
                }
            })
            showQNAToast.observe(viewLifecycleOwner, Observer {
                it.getContentIfNotHandled()?.let {
                    binding.etQuestion.text.clear()
                    imm.hideSoftInputFromWindow(binding.etQuestion.windowToken, 0)
                    if (!isLoading) {
                        isLoading = true
                        binding.recyclerView.post {
                            mAdapter.addLoading()
                        }
                        offsetQNA.value = (mAdapter.itemCount).toString()
                    }
                }
            })
            offsetQNA.observe(viewLifecycleOwner, Observer {
                Log.v(TAG,"offsetQNA => $it")
                Handler(Looper.getMainLooper()).postDelayed({
                    if (isLoading) {
                        isLoading = false
                        mAdapter.removeLoading()
                        mVideoViewModel.getQNAContents()
                    }
                },Constants.ENDLESS_DELAY_VALUE)

            })

        }

    }

    private fun initRVLayout() {
        binding.recyclerView.apply {
            setHasFixedSize(true)
            setItemViewCacheSize(20)
            layoutManager = linearLayoutManager
            if (adapter == null) {
                Log.e(TAG,"adapter is null")
                mAdapter      = QNAContentsRVAdapter()
                mAdapter.setHasStableIds(true)
                adapter       = mAdapter
            }
        }

        if (Preferences.token.isNotEmpty()) {
            // 스크롤: Listener 설정
            scrollListener = object : EndlessRVScrollListener(linearLayoutManager) {
                override fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?) {
                    if (!isLoading && totalItemsCount >= 20) {
                        Log.e(TAG, "EndlessRVScrollListener In")
                        isLoading = true
                        binding.recyclerView.post {
                            mAdapter.addLoading()
                        }
                        mVideoViewModel.offsetQNA.postValue(totalItemsCount.toString())
                    }
                }
            }

            // 스크롤: 이벤트 초기화
            binding.recyclerView.addOnScrollListener(scrollListener)
            scrollListener.resetState()

        } else Log.v(TAG, getString(R.string.content_text_toast_login))
    }

    fun clearAdapter() {
        if (::mAdapter.isInitialized) {
            mAdapter.clear()
        }
    }

    companion object {
        private val TAG = VideoQNASFragment::class.java.simpleName

        fun newInstance() = VideoQNASFragment().apply {
            arguments = bundleOf()
        }
    }

}


