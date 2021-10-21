package com.gongmanse.app.utils

import android.app.Dialog
import android.content.Context
import android.view.WindowManager
import android.widget.ImageView
import com.gongmanse.app.R

class CustomDialog(context: Context) {
    private val dialog = Dialog(context)

    fun myDialog(){


        dialog.apply {
            setContentView(R.layout.layout_counsel_custom_dialog)
            window!!.setLayout(WindowManager.LayoutParams.WRAP_CONTENT,WindowManager.LayoutParams.WRAP_CONTENT)
            setCanceledOnTouchOutside(true)
            setCancelable(true)
        }
        dialog.show()

        var type: String
        val photoButton = dialog.findViewById<ImageView>(R.id.iv_select_photo)
        val videoButton = dialog.findViewById<ImageView>(R.id.iv_select_video)
        val closeButton = dialog.findViewById<ImageView>(R.id.iv_close)
        photoButton.setOnClickListener {
            type = "IMAGE"
            onClickListener.onClick(type)
            dialog.dismiss()
        }
        videoButton.setOnClickListener {
            type = "VIDEO"
            onClickListener.onClick(type)
            dialog.dismiss()
        }
        closeButton.setOnClickListener {
            dialog.dismiss()
        }
    }

    interface ButtonClickListener{
        fun onClick(type : String)
    }
    private lateinit var onClickListener: ButtonClickListener

    fun setOnClickedListener(listener: ButtonClickListener){
        onClickListener = listener
    }
}