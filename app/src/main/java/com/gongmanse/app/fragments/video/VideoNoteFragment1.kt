package com.gongmanse.app.fragments.video

import android.annotation.SuppressLint
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.graphics.Bitmap
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.os.bundleOf
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.R
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.activities.VideoNoteActivity
import com.gongmanse.app.api.video.VideoRepository
import com.gongmanse.app.databinding.FragmentVideoNoteBinding
import com.gongmanse.app.model.*
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.GBLog
import com.gongmanse.app.utils.GraphicView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.jetbrains.anko.support.v4.toast
import java.net.URL

class VideoNoteFragment1 : Fragment() {

    private lateinit var binding: FragmentVideoNoteBinding
    private lateinit var json : NoteJson
    private lateinit var mVideoViewModel: VideoViewModel

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_video_note, container, false)
        setConfigurationLayout(resources.configuration.orientation == ActivityInfo.SCREEN_ORIENTATION_PORTRAIT)
        return binding.root
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        GBLog.v("TAG", "onConfigurationChanged")
        setConfigurationLayout(newConfig.orientation == Configuration.ORIENTATION_PORTRAIT)
    }

    private fun setConfigurationLayout(isPortrait: Boolean) {
        if (isPortrait) {
            val constraints = ConstraintSet()
            constraints.clone(binding.rootLayout)
            constraints.connect(binding.canvasBackground.id, ConstraintSet.START, binding.canvasGuideL.id, ConstraintSet.START)
            constraints.connect(binding.canvasBackground.id, ConstraintSet.END, binding.canvasGuideR.id, ConstraintSet.END)
            constraints.connect(binding.canvasView.id, ConstraintSet.START, binding.canvasGuideL.id, ConstraintSet.START)
            constraints.connect(binding.canvasView.id, ConstraintSet.END, binding.canvasGuideR.id, ConstraintSet.END)
            constraints.applyTo(binding.rootLayout)
        } else {
            val constraints = ConstraintSet()
            constraints.clone(binding.rootLayout)
            constraints.connect(binding.canvasBackground.id, ConstraintSet.START, binding.rootLayout.id, ConstraintSet.START)
            constraints.connect(binding.canvasBackground.id, ConstraintSet.END, binding.rootLayout.id, ConstraintSet.END)
            constraints.connect(binding.canvasView.id, ConstraintSet.START, binding.rootLayout.id, ConstraintSet.START)
            constraints.connect(binding.canvasView.id, ConstraintSet.END, binding.rootLayout.id, ConstraintSet.END)
            constraints.applyTo(binding.rootLayout)
        }

        // 화면 회전 시 노트 이미지 높이와 필기영역 높이 재설정
        if (binding.canvasBackground.childCount > 0) {
            GBLog.i(TAG, "before picY : $picY")

            Handler(Looper.getMainLooper()).postDelayed({
                if (binding.canvasBackground.width <10) return@postDelayed

                // configuration done...
                picY = 0f
                GBLog.v(TAG, "binding.canvasBackground.width : ${binding.canvasBackground.width}")
                for (i in 0 until binding.canvasBackground.childCount) {
                    val iv = binding.canvasBackground.getChildAt(i) as ImageView
                    val lp = iv.layoutParams
                    lp.height = (binding.canvasBackground.width * ratio).toInt()// 화면 크기에 맞춰 이미지 높이 계산
                    binding.canvasBackground.getChildAt(i).layoutParams = lp

                    picY += lp.height
                }
                GBLog.i(TAG, "after picY : $picY")
                binding.canvasView.setLayoutSize(picY)
            }, 300)
        }

    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        Log.d(TAG,"VideoNoteFragment")
        setLiveData()
        binding.canvasView.setLayerType(View.LAYER_TYPE_HARDWARE, null)
        initListener()
//        initNoteData()
        Log.d(TAG,"VideoNoteFragment2")

    }

    fun backNote(json: NoteJson?){
//        GBLog.d("json =>" ,"제이슨 확인 \n $json " )
//        binding.canvasView.setLayoutSize(binding.canvasBackground.height.toFloat())
        binding.canvasView.setLayoutSize(picY)
        binding.canvasView.clear()
        json?.let {
            binding.canvasView.addPaint(it)
        }
        binding.canvasView.requestFocus()
    }

    private var ratio = 0f
    private var picY = 0f
    private var noteData: NoteCanvasData? = null
    private fun setLiveData(){
        Log.d("VideoNoteFragment1@@" ,"setLiveData()...." )
        val mVideoVideoViewModelFactory = VideoViewModelFactory(VideoRepository())
        mVideoViewModel = ViewModelProvider(context as VideoActivity, mVideoVideoViewModelFactory).get(VideoViewModel::class.java)
        if(::mVideoViewModel.isInitialized){
            mVideoViewModel.currentNoteData.observe( this, {
                CoroutineScope(Dispatchers.Main).launch {
                    noteData = it
                    binding.apply {
                        canvasView.setLayoutSize(binding.canvasBackground.height.toFloat())
                        canvasBackground.removeAllViews()
                        canvasView.clear()
                        canvasView.requestFocus()
                    }
                    Log.d("VideoNoteFragment1@@","mVideoId => ${mVideoViewModel.videoId.value}")
                    picY = 0f
                    it?.apply {
                        delay(500L)
                        notes?.let {
                            val lp = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
                            for (path in it) {
                                val imageTask =  VideoNoteActivity.URLtoBitmapTask()
                                    .apply { url = URL("${Constants.FILE_DOMAIN}/$path") }
                                val bitmap = imageTask.execute().get()
                                val resizeBmp = Bitmap.createBitmap(bitmap, 0, 0, (bitmap.width * 0.6).toInt(), bitmap.height)

                                GBLog.i(TAG,"resizeBmp : ${resizeBmp.width}x${resizeBmp.height}")

//                                lp.width = binding.canvasBackground.width
                                ratio = resizeBmp.height.toFloat() / resizeBmp.width
                                GBLog.i(TAG, "ratio : $ratio")
                                lp.height = (binding.canvasBackground.width * ratio).toInt()// 화면 크기에 맞춰 이미지 높이 계산

                                val iv = ImageView(context)
                                iv.scaleType = ImageView.ScaleType.FIT_XY
                                iv.layoutParams = lp

                                iv.setImageBitmap(resizeBmp)

                                binding.canvasBackground.addView(iv)
                                picY += lp.height
                            }
                        }
                        GBLog.e("", "picY : $picY")

                        binding.canvasView.setLayoutSize(picY)
                        binding.canvasView.clear()
                        json?.let {
                            binding.canvasView.addPaint(it)
                        }
                        binding.canvasView.requestFocus()
                        binding.sliding.close()
                    }
                }
            })
        }
    }

    fun noteInvalidate() {
        binding.canvasView.invalidate()
    }

    fun reload() {
//        binding.sliding.close()
//        CoroutineScope(Dispatchers.Main).launch {
//            binding.apply {
//                canvasBackground.clear()
//                canvasBackground.requestLayout()
//                canvasView.requestLayout()
//                canvasBackground.invalidate()
//                canvasView.invalidate()
//            }
//            delay(500L)
//            noteData?.apply {
//                notes?.let {
//                    for (path in it) {
//                        val imageTask =  VideoNoteActivity.URLtoBitmapTask()
//                            .apply { url = URL("${Constants.FILE_DOMAIN}/$path") }
//                        val bitmap = imageTask.execute().get()
//                        binding.canvasBackground.addImage(bitmap)
//                    }
//                }
//            }
//        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initListener() {
        binding.scrollView.setOnScrollChangeListener { v, scrollX, scrollY, oldScrollX, oldScrollY ->
            Log.d(TAG, "scrollX => $scrollX\tscrollY => $scrollY")
            Log.d(TAG, "oldScrollX => $oldScrollX\toldScrollY => $oldScrollY")
        }

        binding.sliding.setOnDrawerOpenListener {openTool()}
        binding.sliding.setOnDrawerCloseListener {closeTool()}

        binding.content.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                R.id.rb_1 -> binding.canvasView.changeColor(GraphicView.MODE_PEN_RED)
                R.id.rb_2 -> binding.canvasView.changeColor(GraphicView.MODE_PEN_GREEN)
                R.id.rb_3 -> binding.canvasView.changeColor(GraphicView.MODE_PEN_BLUE)
                R.id.rb_4 -> binding.canvasView.changeEraser()
            }
        }
        binding.btnCanvasShow.setOnClickListener {
            if (binding.sliding.isOpened) {
                uploadNote()
            } else {
                if (::mVideoViewModel.isInitialized) {
                    val strokes = binding.canvasView.getPaints()
                    Log.d(TAG, "strokes => $strokes")
                    json = NoteJson(Constants.ASPECT_RATIO, strokes)
                    (activity as VideoActivity).moveNoteView(mVideoViewModel.currentNoteData.value,json)
                } else {
                    toast("로딩중입니다.")
                }
            }
        }
    }
    private fun openTool(){
            binding.canvasView.changeDrawing(true)
            binding.handleClose.visibility = View.INVISIBLE
            binding.handleOpen.visibility = View.VISIBLE
            binding.btnCanvasShow.text = resources.getString(R.string.content_button_canvas_save)
    }
    private fun closeTool(){
            Log.d(TAG,"클로즈 진입")
            binding.canvasView.changeDrawing(false)
            binding.handleClose.visibility = View.VISIBLE
            binding.handleOpen.visibility = View.INVISIBLE
            binding.btnCanvasShow.text = resources.getString(R.string.content_button_canvas_show)
    }
    private fun initNoteData() {
        Log.v(TAG, "videoId => ${mVideoViewModel.videoId.value}")
        mVideoViewModel.initNoteData(mVideoViewModel.videoId.value)
    }

    private fun uploadNote(){
        this.context?.let { mVideoViewModel.uploadNote(it, mVideoViewModel.videoId.value, binding.canvasView.getPaints()) }
    }

    companion object {
        private val TAG = VideoNoteFragment1::class.java.simpleName

        fun newInstance() = VideoNoteFragment1().apply {
            arguments = bundleOf()
        }
    }

}