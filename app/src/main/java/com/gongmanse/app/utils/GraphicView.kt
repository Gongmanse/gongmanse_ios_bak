package com.gongmanse.app.utils

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Resources
import android.graphics.*
import android.util.AttributeSet
import android.util.Log
import android.view.MotionEvent
import android.view.View
import com.gongmanse.app.model.NoteJson
import com.gongmanse.app.model.NotePoint
import com.gongmanse.app.model.NoteStroke
import kotlin.math.abs

@SuppressLint("ClickableViewAccessibility")
class GraphicView: View, View.OnTouchListener {

    companion object {
        private val TAG = GraphicView::javaClass.name
        private const val TOUCH_TOLERANCE = 4
        private const val SIZE_PEN = 0.0045146726862302F
        private const val SIZE_ERASER = 0.067720090293454F
        private var mHeight = 0F
        const val MODE_PEN_RED = 1
        const val MODE_PEN_GREEN = 2
        const val MODE_PEN_BLUE = 3
        fun getScreenWidth(): Int {
            return Resources.getSystem().displayMetrics.widthPixels
        }

        fun getScreenHeight(): Int {
            return Resources.getSystem().displayMetrics.heightPixels
        }

    }

    private lateinit var mExtraBitmap: Bitmap
    private lateinit var mExtraCanvas: Canvas
    private val mPaints: ArrayList<NoteStroke> = arrayListOf()
    private val mPath: Path = Path()
    private val mPaint: Paint = Paint().apply {
        color = Color.parseColor(Constants.COLOR_RED)
        isAntiAlias = true
        isDither = true
        style = Paint.Style.STROKE
        strokeJoin = Paint.Join.ROUND
        strokeCap = Paint.Cap.ROUND
        strokeWidth = SIZE_PEN * 1000
    }
    private var mPaintSize = SIZE_PEN // 초기 사이즈
    private var mPaintColor = Constants.COLOR_RED // 초기 색상
    private var isFirst = true
    private var isDrawing = false
    private var mWidth = 0F
    private var mX = 0F
    private var mY = 0F
    private var lastCount = 0

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
        val h = if (heightMeasureSpec > mHeight.toInt()) heightMeasureSpec else mHeight.toInt()
        setMeasuredDimension(w, h)
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        Log.d(TAG, "onSizeChanged width => ${getScreenWidth()}")
        Log.d(TAG, "onSizeChanged height => ${getScreenHeight()}")
        val height: Int = if (mHeight > getScreenHeight()) mHeight.toInt() else getScreenHeight()
        mExtraBitmap = Bitmap.createBitmap(getScreenWidth(), height, Bitmap.Config.ARGB_8888)
        mExtraCanvas = Canvas(mExtraBitmap)
        isFirst = true
    }

    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)
        canvas?.drawBitmap(mExtraBitmap, 0F, 0F, null)
        initPaint()
    }

    private fun initPaint() {
        if (isFirst) {
            lastCount = mPaints.size
            mPaints.forEach { stroke ->
                stroke.points.forEachIndexed { index, point ->
                    Log.e(TAG,"index:$index, point:$point")
                    if (index == 0) drawStart(getRatioX(point.x), getRatioY(point.y))
                    else {
                        val paint = if (stroke.pointColor == null) mPaint else stroke.getPaint()
                        drawing(getRatioX(point.x), getRatioY(point.y), paint)
                    }
                }
                drawEnd()
            }
            isFirst = isFirst.not()
        }
    }

    private fun drawStart(x: Float, y: Float) {
        Log.d(TAG, "ACTION_DOWN: $x $y")
        mPath.reset()
        mPath.moveTo(x, y)
        mX = x
        mY = y
    }

    private fun drawing(x: Float, y: Float, paint: Paint) {
//        Log.d(TAG, "ACTION_MOVE: $x $y ${paint.color}")
        val dx = abs(x - mX)
        val dy = abs(y - mY)
        if (dx >= TOUCH_TOLERANCE || dy >= TOUCH_TOLERANCE) {
            mPath.quadTo(mX, mY, (mX+x)/2, (mY+y)/2)
            mX = x
            mY = y
            mExtraCanvas.drawPath(mPath, paint)
        }
    }

    private fun drawEnd() {
        Log.d(TAG, "ACTION_UP")
        mPath.reset()
        mPath.close()
    }

    private fun touchStart(x: Float, y: Float) {
        // 초기화 및 좌표 업로드
        val points = arrayListOf(NotePoint(getReverseRatioX(x), getReverseRatioY(y)))
        val stroke = NoteStroke(points, mPaintColor,  Constants.STROKE_CAP, Constants.STROKE_JOIN, mPaintSize, Constants.MITER_LIMIT)
        mPaints.add(stroke)
    }

    private fun touchMove(x: Float, y: Float) {
        // 좌표 업로드
        mPaints.last().points.add(NotePoint(getReverseRatioX(x), getReverseRatioY(y)))
    }

    override fun onTouch(v: View?, event: MotionEvent?): Boolean {
        parent.requestDisallowInterceptTouchEvent(isDrawing)
        if (isDrawing.not()) return false
        event?.apply {
            when (action) {
                MotionEvent.ACTION_DOWN -> {
                    touchStart(x, y)
                    drawStart(x, y)
                }
                MotionEvent.ACTION_UP -> {
                    drawEnd()
                }
                MotionEvent.ACTION_MOVE -> {
                    touchMove(x, y)
                    drawing(x, y, mPaint)
                    invalidate()
                }
            }
        }
        return true
    }

    // 비율 연산
    private fun getRatioX(value: Float): Float {
        return value * this.width
    }

    private fun getRatioY(value: Float): Float {
        return value * mHeight
    }

    private fun getReverseRatioX(value: Float): Float {
        return value / this.width
    }

    private fun getReverseRatioY(value: Float): Float {
        return value / mHeight
    }

    // 크기 변경
    fun setLayoutSize(height: Float) {
        mHeight = height
        invalidate()
        requestLayout()
    }

    fun changeDrawing(isCheck: Boolean) {
        this.isDrawing = isCheck
    }

    fun changeColor(color: Int) {
        this.mPaintSize = SIZE_PEN
        this.mPaintColor = when (color) {
            MODE_PEN_RED -> Constants.COLOR_RED
            MODE_PEN_GREEN -> Constants.COLOR_GREEN
            MODE_PEN_BLUE -> Constants.COLOR_BLUE
            else -> Constants.COLOR_RED
        }
        mPaint.xfermode = null
        mPaint.strokeWidth = mPaintSize * 1000
        mPaint.color = Color.parseColor(mPaintColor)
    }

    fun changeEraser() {
        this.mPaintSize = SIZE_ERASER
        this.mPaintColor = Constants.COLOR_TRANSPARENT
        mPaint.xfermode = PorterDuffXfermode(PorterDuff.Mode.CLEAR)
        mPaint.strokeWidth = mPaintSize * 1000
        mPaint.color = Color.TRANSPARENT
    }

    // 이전 페인트 추가
    fun addPaint(item: NoteJson?) {
        item?.apply {
            mPaints.addAll(strokes)
            invalidate()
        }
    }

    // 페인트 정보
    fun getPaints(): ArrayList<NoteStroke> {
        return mPaints
    }

    // 초기화
    fun clear() {
        mPath.reset()
        mPaints.clear()
        if (::mExtraCanvas.isInitialized) mExtraCanvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)
        mPaintSize = SIZE_PEN // 초기 사이즈
        mPaintColor = Constants.COLOR_RED // 초기 색상
        isFirst = true
        lastCount = 0
        isDrawing = false
        invalidate()
    }

}