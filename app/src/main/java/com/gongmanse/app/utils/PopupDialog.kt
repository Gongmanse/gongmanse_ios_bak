package com.gongmanse.app.utils

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.Point
import android.graphics.drawable.ColorDrawable
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.TextView
import com.gongmanse.app.R
import java.text.SimpleDateFormat
import java.util.*

class PopupDialog(context: Context) {
    private val dialog = Dialog(context)

    fun myDialog(){
        dialog.apply {
            setContentView(R.layout.layout_popup_dialog)
            window!!.setLayout(WindowManager.LayoutParams.WRAP_CONTENT,WindowManager.LayoutParams.WRAP_CONTENT)

            val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val display = windowManager.defaultDisplay
            val size = Point()
            display.getSize(size)

            val params: ViewGroup.LayoutParams? = dialog.window?.attributes
            val deviceWidth = size.x
            params?.width = (deviceWidth * 0.7).toInt()
            dialog.window?.attributes = params as WindowManager.LayoutParams
            dialog.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
            
            setCanceledOnTouchOutside(true)
            setCancelable(true)
        }
        dialog.show()

        val close1weekButton = dialog.findViewById<TextView>(R.id.btn_1week_close)
        val closeButton = dialog.findViewById<TextView>(R.id.btn_close)
        close1weekButton.setOnClickListener {
            val format = SimpleDateFormat("yyyy-MM-dd", Locale.KOREA)
            val current = format.format(System.currentTimeMillis())
            GBLog.i("TAG", "current : $current")
            Preferences.noShowPopup = current
            dialog.dismiss()
        }
        closeButton.setOnClickListener {
            dialog.dismiss()
        }
    }
}