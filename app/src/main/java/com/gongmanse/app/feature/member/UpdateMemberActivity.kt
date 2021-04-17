package com.gongmanse.app.feature.member

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.ActionBar
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.R
import com.gongmanse.app.data.network.member.MemberRepository
import com.gongmanse.app.databinding.ActivityUpdateMemberBinding
import gun0912.tedimagepicker.builder.TedImagePicker
import kotlinx.android.synthetic.main.activity_update_member.view.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class UpdateMemberActivity : AppCompatActivity(), View.OnClickListener {

    private lateinit var binding: ActivityUpdateMemberBinding
    private lateinit var mActionbar: ActionBar
    private lateinit var mMemberViewModel: MemberViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        bindUI()
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.cv_profile -> {
                TedImagePicker.with(this).start {
                    mMemberViewModel.profile.set(it.toString())
                }
            }
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        Log.v(TAG, "onSupportNavigateUp")
        finish()
        return true
    }

    private fun bindUI() {
        binding = ActivityUpdateMemberBinding.inflate(layoutInflater).apply {
            this@UpdateMemberActivity.let { context ->
                val mMemberViewModelFactory = MemberViewModelFactory(MemberRepository())
                mMemberViewModel = ViewModelProvider(context, mMemberViewModelFactory).get(MemberViewModel::class.java)
                viewModel = mMemberViewModel
                lifecycleOwner = context
            }
        }
        CoroutineScope(Dispatchers.Main).launch {
            setContentView(binding.root)
            mMemberViewModel.getProfile()
            setupActionbar()
            setupMatchPassword()
        }
    }

    private fun setupActionbar() {
        setSupportActionBar(binding.toolbar)
        mActionbar = supportActionBar!!
        mActionbar.setDisplayShowTitleEnabled(false)
        mActionbar.setDisplayHomeAsUpEnabled(true)
    }

    private fun setupMatchPassword() {
        mMemberViewModel.disposables.observe(this, {
            binding.btnApply.isEnabled = it?:false
        })
    }

    companion object {
        private val TAG = UpdateMemberActivity::class.java.simpleName
    }

}