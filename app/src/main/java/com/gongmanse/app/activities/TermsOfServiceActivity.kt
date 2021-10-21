package com.gongmanse.app.activities

import android.annotation.SuppressLint
import android.os.Bundle
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.adapter.loadWebViewUrl
import com.gongmanse.app.databinding.ActivityTermsOfServiceBinding
import com.gongmanse.app.utils.Constants

@Suppress("DEPRECATION")
class TermsOfServiceActivity : AppCompatActivity() {

    companion object {
        private val TAG = TermsOfServiceActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityTermsOfServiceBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_terms_of_service)
        initView()
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initView() {
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_TERMS_OF_SERVICE
        binding.layoutToolbar.btnClose.setOnClickListener { onBackPressed() }

        binding.apply {
            layoutToolbar.title = Constants.ACTIONBAR_TITLE_TERMS_OF_SERVICE
            layoutToolbar.btnClose.setOnClickListener { onBackPressed() }
            val url = Constants.WEB_VIEW_DOMAIN+Constants.TERMS_OF_SERVICE_DOMAIN
            loadWebViewUrl(wvTermsOfService, url)
        }

    }
}