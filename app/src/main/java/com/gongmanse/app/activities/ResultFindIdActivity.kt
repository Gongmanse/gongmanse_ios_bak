package com.gongmanse.app.activities

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ActivityResultFindIdBinding
import com.gongmanse.app.utils.Constants
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class ResultFindIdActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = ResultFindIdActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityResultFindIdBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_result_find_id)
        if (intent.hasExtra(Constants.EXTRA_KEY_USER_NAME)) {
            val username = intent.getStringExtra(Constants.EXTRA_KEY_USER_NAME)
            Log.d(TAG, "username => $username")
            binding.setVariable(BR.username, username)
        }
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.btn_login -> finish()
            R.id.btn_find_password -> findPassword()
        }
    }

    private fun findPassword() {
        startActivity(intentFor<FindPasswordActivity>().singleTop())
        finish()
    }
}