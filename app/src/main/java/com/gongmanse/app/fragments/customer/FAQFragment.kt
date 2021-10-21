package com.gongmanse.app.fragments.customer

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.databinding.ObservableArrayList
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import com.gongmanse.app.R
import com.gongmanse.app.adapter.FAQRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentFaqBinding
import com.gongmanse.app.model.FAQ
import com.gongmanse.app.model.FAQData
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class FAQFragment : Fragment() {

    companion object {
        private var TAG = FAQFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentFaqBinding
    private lateinit var mAdapter: FAQRVAdapter
    private val linearLayoutManager = LinearLayoutManager(context)


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_faq, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        initRVLayout()
        loadFAQList()
    }

    private fun initRVLayout() {
        Log.d(TAG, "initRVLayout")
        val items = ObservableArrayList<FAQData>()
        mAdapter = FAQRVAdapter().apply { addItems(items) }
        binding.rvFaq.apply {
            adapter = mAdapter
            layoutManager = linearLayoutManager
            addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL))

        }
    }

    private fun loadFAQList() {
        Log.d(TAG, "loadFAQList()")
        RetrofitClient.getService().getFAQList().enqueue( object : Callback<FAQ> {
            override fun onFailure(call: Call<FAQ>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")

            }

            override fun onResponse(call: Call<FAQ>, response: Response<FAQ>) {
                if (response.isSuccessful) {
                    Log.i(TAG, "onResponseBody => ${response.body()}")
                    response.body()?.apply { this.data.let { mAdapter.addItems(it) } }
                } else Log.e(TAG, "Failed ResponseCode => ${response.code()}")
            }
        })


    }


}