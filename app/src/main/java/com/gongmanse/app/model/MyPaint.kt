package com.gongmanse.app.model

import android.graphics.Bitmap
import android.graphics.Paint
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class MyPaint (
    val startX: Float = 0F,
    val startY: Float = 0F,
    val endX: Float = 0F,
    val endY: Float = 0F,
    val mode: Int = Constants.MODE_PEN,
    val paint: Paint? = null
): Serializable

data class MyPicture (
    val x: Float = 0F,
    val y: Float = 0F,
    val picture: Bitmap? = null,
    val paint: Paint? = null
): Serializable