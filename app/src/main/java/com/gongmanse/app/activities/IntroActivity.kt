package com.gongmanse.app.activities

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.viewpager2.widget.ViewPager2
import com.gongmanse.app.R
import com.gongmanse.app.adapter.IntroVPAdapter
import com.gongmanse.app.utils.Preferences
import com.rd.PageIndicatorView
import kotlinx.android.synthetic.main.activity_intro.*
import kotlin.system.exitProcess

class IntroActivity : AppCompatActivity() {

    private lateinit var mVPAdapter: IntroVPAdapter
    private lateinit var viewPager: ViewPager2
    private lateinit var indicator: PageIndicatorView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_intro)
        initView()
    }

    override fun onDestroy() {
        super.onDestroy()
        viewPager.unregisterOnPageChangeCallback(callback)
    }

    private fun initView(){
        mVPAdapter = IntroVPAdapter(supportFragmentManager, lifecycle)
        viewPager = findViewById(R.id.view_pager2)
        indicator = findViewById(R.id.indicator)

        viewPager.adapter = mVPAdapter
        viewPager.registerOnPageChangeCallback(callback)

        btn_intro_next.setOnClickListener {
            Preferences.first = false
            Preferences.mobileData = true
            finish()
        }
    }

    private val callback = object : ViewPager2.OnPageChangeCallback() {
        override fun onPageSelected(position: Int) {
            super.onPageSelected(position)
            indicator.setSelected(position)
        }
    }

    override fun onBackPressed() {
        ActivityCompat.finishAffinity(this)
        exitProcess(0)
    }

}