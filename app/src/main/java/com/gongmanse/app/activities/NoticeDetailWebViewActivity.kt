package com.gongmanse.app.activities

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.adapter.loadWebViewUrl
import com.gongmanse.app.databinding.ActivityNoticeDetailWebViewBinding
import com.gongmanse.app.model.EventData
import com.gongmanse.app.model.NoticeData
import com.gongmanse.app.utils.Constants


class NoticeDetailWebViewActivity : AppCompatActivity() {

    companion object {
        private val TAG = NoticeDetailWebViewActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityNoticeDetailWebViewBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_notice_detail_web_view)
        initView()
    }

    private fun initView() {
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_NOTICE
        binding.layoutToolbar.btnClose.setOnClickListener { onBackPressed() }
        initData()
    }

    private fun initData() {
        if (intent.hasExtra(Constants.EXTRA_KEY_NOTICE)) {
            intent.getSerializableExtra(Constants.EXTRA_KEY_NOTICE).let {
                val noticeData = it as NoticeData
                Log.i(TAG, "NoticeData => $noticeData")
                val noticeId = noticeData.id
                showWebView(noticeId, Constants.EXTRA_KEY_NOTICE)
            }
        }
        if (intent.hasExtra(Constants.EXTRA_KEY_EVENT)) {
            intent.getSerializableExtra(Constants.EXTRA_KEY_EVENT).let {
                val eventData = it as EventData
                Log.i(TAG, "EventData => $eventData")
                val eventId = eventData.id
                showWebView(eventId, Constants.EXTRA_KEY_EVENT)
            }
        }
    }

    private fun showWebView(id: String?, extraKey: String ) {
        Constants.apply {
            val noticeUrl = WEB_VIEW_DOMAIN+NOTICE_VALUE_WEB_VIEW+id
            val eventUrl  = NOTICE_EVENT_VALUE_DOMAIN+id

            binding.wvNotice.apply {
                when(extraKey) {
                    EXTRA_KEY_NOTICE -> loadWebViewUrl(this, noticeUrl)
                    EXTRA_KEY_EVENT  -> loadWebViewUrl(this, eventUrl)
                    else             -> loadWebViewUrl(this, WEB_VIEW_DOMAIN)
                }
            }
        }
    }
}