package com.gongmanse.app.model

import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import androidx.databinding.BaseObservable
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class NoteCanvas (
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: NoteCanvasData?
): BaseObservable(), Serializable

data class NoteCanvasData (
    @SerializedName(Constants.RESPONSE_KEY_JSON_POINT) val json: NoteJson?,
    @SerializedName(Constants.RESPONSE_KEY_NOTES) val notes: List<String>?
): BaseObservable(), Serializable

data class NoteJson (
    @SerializedName(Constants.RESPONSE_KEY_ASPECT_RATIO) val ratio: String,
    @SerializedName(Constants.RESPONSE_KEY_STROKES) val strokes: ArrayList<NoteStroke>
): BaseObservable(), Serializable

data class NoteStroke(
    @SerializedName(Constants.RESPONSE_KEY_POINTS) val points: ArrayList<NotePoint>,
    @SerializedName(Constants.RESPONSE_KEY_COLOR) val pointColor: String?,
    @SerializedName(Constants.RESPONSE_KEY_CAP) val cap: String,
    @SerializedName(Constants.RESPONSE_KEY_JOIN) val join: String,
    @SerializedName(Constants.RESPONSE_KEY_SIZE) val size: Float,
    @SerializedName(Constants.RESPONSE_KEY_MITER_LIMIT) val miterLimit: Int
): BaseObservable(), Serializable {
    fun getPaint(): Paint {
        return Paint().apply {
            if (pointColor != Constants.COLOR_TRANSPARENT) {
                xfermode = null
                color = Color.parseColor(pointColor)
            } else {
                xfermode = PorterDuffXfermode(PorterDuff.Mode.CLEAR)
                Color.TRANSPARENT
            }
            style = Paint.Style.STROKE
            strokeCap = Paint.Cap.ROUND
            strokeJoin = Paint.Join.ROUND
            strokeWidth = size * 1000
            isAntiAlias = true
            isDither = true
        }
    }
}

data class NotePoint (
    @SerializedName(Constants.RESPONSE_KEY_POINTS_X) var x: Float,
    @SerializedName(Constants.RESPONSE_KEY_POINTS_Y) var y: Float
): BaseObservable(), Serializable
