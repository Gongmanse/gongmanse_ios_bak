package com.gongmanse.app.model

import android.graphics.Paint
import android.graphics.Path
import androidx.databinding.BaseObservable
import java.io.Serializable

data class PaintPoint(
    val x: Float = 0F,
    val y: Float = 0F,
    val isDraw: Boolean = false,
    val paint: Paint? = null
): BaseObservable(), Serializable

data class PointPath(
    val path: Path? = null,
    val paint: Paint? = null,
    val isDraw: Boolean = false
): BaseObservable(), Serializable

data class Pen(
    var x: Float, //펜의 좌표
    var y: Float, //현재 움직임 여부
    var moveStatus: Int, //펜 색
    var color: Int, //펜 두께
    var size: Int
): BaseObservable(), Serializable {
    /**
     * jhChoi - 201124
     * 현재 pen의 상태가 움직이는 상태인지 반환합니다.
     */
    val isMove: Boolean
        get() = moveStatus == STATE_MOVE

    companion object {
        const val STATE_START = 0 //펜의 상태(움직임 시작)
        const val STATE_MOVE = 1 //펜의 상태(움직이는 중)
    }
}
