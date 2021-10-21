package com.gongmanse.app.fragments.sheet

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.databinding.DialogSheetSelectionOfVideoPlaySpeedBinding
import com.gongmanse.app.listeners.OnVideoOptionListener

class SelectionSheetVideoPlaySpeed(private val listener: OnVideoOptionListener, private var playSpeed: Int): BottomSheetDialogFragment() {

    companion object {
        const val OPTION_SPEED_DEFAULT = 0
        const val OPTION_SPEED_15      = 1
        const val OPTION_SPEED_125     = 2
        const val OPTION_SPEED_075     = 3
        const val OPTION_SPEED_05      = 4
    }

    private lateinit var binding: DialogSheetSelectionOfVideoPlaySpeedBinding

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.dialog_sheet_selection_of_video_play_speed, container, false)
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
        binding.setVariable(BR.position, playSpeed)
        binding.btnClose.setOnClickListener(onDismiss)
        binding.btnPlaySpeedDefault.setOnClickListener(onPlaySpeedChange)
        binding.btnPlaySpeed15.setOnClickListener(onPlaySpeedChange)
        binding.btnPlaySpeed125.setOnClickListener(onPlaySpeedChange)
        binding.btnPlaySpeed075.setOnClickListener(onPlaySpeedChange)
        binding.btnPlaySpeed05.setOnClickListener(onPlaySpeedChange)
    }

    private val onDismiss = View.OnClickListener { dismiss() }

    private val onPlaySpeedChange = View.OnClickListener {
        when (it.id) {
            R.id.btn_play_speed_default -> listener.selectionPlaySpeed(OPTION_SPEED_DEFAULT)
            R.id.btn_play_speed_15 -> listener.selectionPlaySpeed(OPTION_SPEED_15)
            R.id.btn_play_speed_125 -> listener.selectionPlaySpeed(OPTION_SPEED_125)
            R.id.btn_play_speed_075 -> listener.selectionPlaySpeed(OPTION_SPEED_075)
            R.id.btn_play_speed_05 -> listener.selectionPlaySpeed(OPTION_SPEED_05)
        }
    }
}