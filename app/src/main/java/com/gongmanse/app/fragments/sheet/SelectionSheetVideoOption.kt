package com.gongmanse.app.fragments.sheet

import android.os.Build
import android.os.Bundle
import android.text.Html
import android.text.Spanned
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.R
import com.gongmanse.app.databinding.DialogSheetSelectionOfVideoOptionBinding
import com.gongmanse.app.listeners.OnVideoOptionListener

class SelectionSheetVideoOption(private val listener: OnVideoOptionListener, private var isCaption: Boolean, private var playSpeed: Int): BottomSheetDialogFragment() {

    companion object {
        const val OPTION_SPEED_DEFAULT = 0
        const val OPTION_SPEED_15      = 1
        const val OPTION_SPEED_125     = 2
        const val OPTION_SPEED_075     = 3
        const val OPTION_SPEED_05      = 4
    }

    private lateinit var binding: DialogSheetSelectionOfVideoOptionBinding

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.dialog_sheet_selection_of_video_option, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    override fun onStart() {
        super.onStart()
        val behavior = BottomSheetBehavior.from(requireView().parent as View)
        behavior.state = BottomSheetBehavior.STATE_EXPANDED
    }

    private fun initView() {
        binding.btnClose.setOnClickListener(onDismiss)
        binding.btnPlaySpeed.setOnClickListener(onPlaySpeed)
        binding.btnCaption.setOnClickListener(onCaption)
        setCaptionText()
        setPlaySpeedText()
    }

    private val onDismiss = View.OnClickListener { dismiss() }

    private val onCaption = View.OnClickListener {
        isCaption = isCaption.not()
        listener.selectionOption(0)
        setCaptionText()
    }

    private val onPlaySpeed = View.OnClickListener {
        listener.selectionOption(1)
    }

    private fun setCaptionText() {
        binding.btnCaption.text =
            if (isCaption) resources.getString(R.string.content_text_caption_on).htmlToString()
            else resources.getString(R.string.content_text_caption_off).htmlToString()
    }

    private fun setPlaySpeedText() {
        binding.btnPlaySpeed.text =
            when (playSpeed) {
                OPTION_SPEED_DEFAULT -> resources.getString(R.string.content_text_play_speed_default).htmlToString()
                OPTION_SPEED_15 -> resources.getString(R.string.content_text_play_speed_15).htmlToString()
                OPTION_SPEED_125 -> resources.getString(R.string.content_text_play_speed_125).htmlToString()
                OPTION_SPEED_075 -> resources.getString(R.string.content_text_play_speed_075).htmlToString()
                OPTION_SPEED_05 -> resources.getString(R.string.content_text_play_speed_05).htmlToString()
                else -> resources.getString(R.string.content_text_play_speed_default).htmlToString()
            }
    }

    @Suppress("DEPRECATION")
    private fun String.htmlToString(): Spanned {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Html.fromHtml(this, Html.FROM_HTML_MODE_LEGACY)
        } else {
            Html.fromHtml(this)
        }
    }

}