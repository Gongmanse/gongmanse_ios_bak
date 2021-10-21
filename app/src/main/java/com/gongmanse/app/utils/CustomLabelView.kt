package com.gongmanse.app.utils

import android.content.Context
import android.content.res.TypedArray
import android.util.AttributeSet
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import androidx.cardview.widget.CardView
import androidx.core.content.ContextCompat
import com.gongmanse.app.R
import kotlinx.android.synthetic.main.custom_label_view.view.*
import org.jetbrains.anko.textSizeDimen

class CustomLabelView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null, defStyle: Int = 0): LinearLayout(context, attrs, defStyle) {

    init {
        val view = inflate(context, R.layout.custom_label_view, this)
        attrs?.let {
            val typedArray = context.obtainStyledAttributes(it, R.styleable.custom_label_view)
            val bgColor = typedArray.getColor(R.styleable.custom_label_view_bg, ContextCompat.getColor(context, R.color.main_color))
            val txt = typedArray.getString(R.styleable.custom_label_view_txt)
            val txtSize = typedArray.getDimensionPixelSize(R.styleable.custom_label_view_txtSize, context.resources.getDimensionPixelSize(R.dimen.sp_10))
            view.bg.setCardBackgroundColor(bgColor)
            view.txt.setTextSize(TypedValue.COMPLEX_UNIT_PX, txtSize.toFloat())
            view.txt.text = txt
            typedArray.recycle()
        }
    }

}