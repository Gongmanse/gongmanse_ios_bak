package com.gongmanse.app.activities.customer

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.adapter.CustomerServiceTabAdapter
import com.gongmanse.app.databinding.ActivityCustomerServiceBinding
import com.gongmanse.app.utils.Constants

class CustomerServiceActivity : AppCompatActivity() {

    companion object {
        private lateinit var binding: ActivityCustomerServiceBinding
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_customer_service)
        initView()
    }

    private fun initView() {
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_CUSTOMER_SERVICE
        binding.layoutToolbar.btnClose.setOnClickListener { onBackPressed() }
        val mAdapter = CustomerServiceTabAdapter(supportFragmentManager)
        binding.viewPager.apply {
            adapter = mAdapter
            offscreenPageLimit = mAdapter.count
            binding.tabLayout.setupWithViewPager(this)
        }
    }
}