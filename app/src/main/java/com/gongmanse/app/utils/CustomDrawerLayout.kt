package com.gongmanse.app.utils

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout

class CustomDrawerLayout : DrawerLayout {

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet, defStyle: Int) : super(context, attrs, defStyle)

    override fun onInterceptTouchEvent(ev: MotionEvent?): Boolean {
        return try {
            super.onInterceptTouchEvent(ev)
        } catch (e: IllegalAccessException) {
            e.printStackTrace()
            false
        }
    }

    override fun closeDrawer(gravity: Int) {
        super.closeDrawer(GravityCompat.END)
    }

    override fun openDrawer(gravity: Int) {
        super.openDrawer(GravityCompat.END)
    }
}