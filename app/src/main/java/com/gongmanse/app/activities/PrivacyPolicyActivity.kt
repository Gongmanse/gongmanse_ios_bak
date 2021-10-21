package com.gongmanse.app.activities

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.adapter.loadWebViewUrl
import com.gongmanse.app.databinding.ActivityPrivacyPolicyBinding
import com.gongmanse.app.utils.Constants

class PrivacyPolicyActivity : AppCompatActivity() {

    companion object {
        private val TAG = PrivacyPolicyActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityPrivacyPolicyBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_privacy_policy)
        initView()
    }

    private fun initView() {
        binding.apply {
            layoutToolbar.title = Constants.ACTIONBAR_TITLE_PRIVACY_POLICY
            layoutToolbar.btnClose.setOnClickListener { onBackPressed() }
            val url = Constants.WEB_VIEW_DOMAIN + Constants.PRIVACY_POLICY_DOMAIN
            loadWebViewUrl(wvPrivacyPolicy, url)
        }

    }
}