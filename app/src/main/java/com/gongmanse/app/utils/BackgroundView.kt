package com.gongmanse.app.utils

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.PorterDuff
import android.util.AttributeSet
import android.util.Log
import android.view.MotionEvent
import android.view.View
import androidx.core.content.ContextCompat
import com.gongmanse.app.R
import com.gongmanse.app.model.MyPicture

@SuppressLint("ClickableViewAccessibility")
class BackgroundView: View, View.OnTouchListener {

    companion object {
        private var mWidth = 0
        private var mHeight = 0
    }

    private var mPictures: ArrayList<MyPicture> = arrayListOf()
    private var picX = 0F
    private var picY = 0F

    constructor(context: Context?): super(context)
    constructor(context: Context?, attributeSet: AttributeSet?): super(context, attributeSet)
    constructor(context: Context?, attributeSet: AttributeSet?, defStyleAttr: Int): super(context, attributeSet, defStyleAttr)

    init {
        this.setOnTouchListener(this)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        val minW = paddingLeft + paddingRight + suggestedMinimumWidth + measuredWidth + 100
        val w = when (MeasureSpec.getMode(widthMeasureSpec)) {
            MeasureSpec.AT_MOST -> minW
            MeasureSpec.UNSPECIFIED -> widthMeasureSpec
            MeasureSpec.EXACTLY -> MeasureSpec.getSize(widthMeasureSpec)
            else -> 0
        }
        val h = if (heightMeasureSpec > picY.toInt()) heightMeasureSpec else picY.toInt()
        setMeasuredDimension(w, h)
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        mWidth = this.width
        mHeight = this.height
    }

    override fun onDraw(canvas: Canvas?) {
        if (mPictures.isNotEmpty()) {
            for (picture in mPictures) {
                canvas?.drawBitmap(picture.picture!!, picture.x, picture.y, picture.paint)
            }
        } else {
            canvas?.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)
        }
    }

    override fun onTouch(v: View?, event: MotionEvent?): Boolean {
        return false
    }

    fun addImage(picture: Bitmap) {
        Log.e("BackgroundView", "picture => ${picture.width} / ${picture.height}")
        val crop = if (resources.getString(R.string.screen_type) == "tablet") {
            Log.d("BackgroundView", "Tablet : @@@@@@@@@@@@@@@")
            Bitmap.createBitmap(picture, 0, 0, (picture.width * 0.8).toInt(), picture.height)
        } else {
            Log.d("BackgroundView", "Mobile : @@@@@@@@@@@@@@@")
            Bitmap.createBitmap(picture, 0, 0, (picture.width * 0.6).toInt(), picture.height)
        }
        val ratio = mWidth.toFloat() /crop.width.toFloat()
        Log.e("BackgroundView", "crop => ${crop.width} / ${crop.height} => $ratio")
        val bitmap = Bitmap.createScaledBitmap(crop, mWidth, (crop.height * ratio).toInt(), true)
        Log.e("BackgroundView", "bitmap => ${bitmap.width} / ${bitmap.height}")
        mPictures.add(MyPicture(picX, picY, bitmap, null))
        picY += bitmap.height
        invalidate()
        requestLayout()
    }

    fun clear() {
        mPictures.clear()
        picX = 0F
        picY = 0F
        requestLayout()
        invalidate()
    }

    fun getLayoutHeight(): Float {
        return picY
    }
}