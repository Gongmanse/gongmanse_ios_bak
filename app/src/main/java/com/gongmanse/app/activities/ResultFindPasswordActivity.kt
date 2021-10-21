package com.gongmanse.app.activities

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ActivityResultFindPasswordBinding

class ResultFindPasswordActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = ResultFindPasswordActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityResultFindPasswordBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_result_find_password)
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.btn_login -> finish()
        }
    }
}