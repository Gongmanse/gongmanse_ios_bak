package com.gongmanse.app.activities

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.adapter.PassTabAdapter
import com.gongmanse.app.databinding.ActivityPassBinding
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class PassActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = PassActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityPassBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_pass)
        initView()
    }

    private fun initView() {
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_PASS
        val mAdapter = PassTabAdapter(supportFragmentManager)
        binding.viewPager.apply {
            adapter = mAdapter
            offscreenPageLimit = mAdapter.count
            binding.tabLayout.setupWithViewPager(this)
        }
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            // 닫기
            R.id.btn_close -> Commons.close(this)
        }
    }

}