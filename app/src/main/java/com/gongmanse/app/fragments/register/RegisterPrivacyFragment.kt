package com.gongmanse.app.fragments.register

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.activities.RegisterActivity
import com.gongmanse.app.adapter.loadWebViewUrl
import com.gongmanse.app.databinding.FragmentRegisterPrivacyBinding
import com.gongmanse.app.utils.Constants

class RegisterPrivacyFragment: Fragment() {

    companion object {
        private val TAG = RegisterPrivacyFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentRegisterPrivacyBinding

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_register_privacy, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }


    private fun initView() {
        binding.apply {
            // Click
            nextBtnEnable(false)
            cbAll.setOnClickListener(checkedAll)
            // CheckedChange
            cbTermsOfService.setOnCheckedChangeListener { _, isChecked -> cbAll.isChecked = if (isChecked and cbPrivacy.isChecked) isChecked else false }
            cbPrivacy.setOnCheckedChangeListener { _, isChecked -> cbAll.isChecked = if (isChecked and cbTermsOfService.isChecked) isChecked else false }
            cbAll.setOnCheckedChangeListener { _, isChecked -> nextBtnEnable(isChecked) }

            val privacyUrl = Constants.WEB_VIEW_DOMAIN + Constants.PRIVACY_POLICY_DOMAIN
            val termsUrl   = Constants.WEB_VIEW_DOMAIN + Constants.TERMS_OF_SERVICE_DOMAIN
            setWebView(wvPrivacyPolicy, privacyUrl)
            setWebView(wvTermsOfService, termsUrl)

        }

    }

    private val nextView = View.OnClickListener {
        Log.d(TAG, "click => next")
        (activity as RegisterActivity).nextView(Constants.REGISTER_TYPE_FORM)
    }

    private val checkedAll = View.OnClickListener {
        binding.apply {
            cbAll.isChecked.let { isChecked ->
                Log.d(TAG, "All Checked => $isChecked")
                cbAll.isChecked = isChecked
                cbTermsOfService.isChecked = isChecked
                cbPrivacy.isChecked = isChecked
            }
        }
    }

    private fun nextBtnEnable(isEnabled: Boolean) {
        binding.layoutButtonNext.btnNext.apply {
            isClickable = isEnabled
            setCardBackgroundColor(ContextCompat.getColorStateList(context, if (isEnabled) R.color.main_color else R.color.gray))
            setOnClickListener(if (isEnabled) nextView else null)
        }
    }

    private fun setWebView(webView: WebView, url: String?) {
        loadWebViewUrl(webView, url)
    }
}