package com.gongmanse.app.fragments.register

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.gongmanse.app.R
import com.gongmanse.app.activities.RegisterActivity
import com.gongmanse.app.databinding.FragmentRegisterDoneBinding

class RegisterDoneFragment : Fragment() {

    companion object {
        private val TAG = RegisterDoneFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentRegisterDoneBinding

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_register_done, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        binding.btnGoMain.setOnClickListener(goMain)
    }

    private val goMain = View.OnClickListener {
        Log.d(TAG, "Click to Go Main.")
        (activity as RegisterActivity).done()
    }

}