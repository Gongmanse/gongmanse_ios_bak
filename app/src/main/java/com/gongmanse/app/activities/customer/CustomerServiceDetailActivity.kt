package com.gongmanse.app.activities.customer

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityCustomerServiceDetailBinding
import com.gongmanse.app.model.OneToOne
import com.gongmanse.app.model.OneToOneData
import com.gongmanse.app.utils.Constants
import org.jetbrains.anko.alert
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class CustomerServiceDetailActivity : AppCompatActivity() {

    companion object {
        private val TAG = CustomerServiceDetailActivity::class.java.simpleName
        const val EDIT_REQUEST_CODE = 1000
    }

    private lateinit var binding: ActivityCustomerServiceDetailBinding
    private lateinit var mData: OneToOneData
    private var id: Int? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_customer_service_detail)
        initView()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == EDIT_REQUEST_CODE) {
            when(resultCode) {
                AddOneToOneActivity.EDIT_RESPONSE_CODE -> {
                    if (data != null){
                        id = data.getIntExtra(Constants.EXTRA_KEY_QNA_ID, 0)
                        loadCustomerServiceDetail(id)
                    } else {
                        Log.e(TAG,"data is null")
                    }
                }
            }
        }
    }

    private fun initView() {
        initData()
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_CUSTOMER_SERVICE
        binding.layoutToolbar.btnClose.setOnClickListener { onBackPressed() }
        binding.tvEdit.setOnClickListener {
            val intent = Intent(this, AddOneToOneActivity::class.java)
            intent.putExtra(Constants.EXTRA_KEY_ONE_TO_ONE, mData)
            startActivityForResult(intent, EDIT_REQUEST_CODE)
        }
        binding.tvDelete.setOnClickListener {
            alert(title = "1:1 문의", message = "삭제 하시겠습니까?") {
                positiveButton(getString(R.string.content_button_positive)) {
                    deleteMyQNA(mData.id)
                    it.dismiss()
                    onBackPressed()
                }
                negativeButton(getString(R.string.content_button_negative)) { it.dismiss() }
            }.show()

        }
    }

    private fun initData() {
        if (intent.hasExtra(Constants.EXTRA_KEY_ONE_TO_ONE)) {
            intent.getSerializableExtra(Constants.EXTRA_KEY_ONE_TO_ONE).let {
                mData = it as OneToOneData
                id = mData.id
                if (id != null) loadCustomerServiceDetail(id)
                Log.i(TAG, "OneToOneData => $mData")
            }
        }
    }

    private fun loadCustomerServiceDetail(qna_id: Int?) {
        RetrofitClient.getService().getCustomerService(qna_id).enqueue( object : Callback<OneToOne> {
            override fun onFailure(call: Call<OneToOne>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<OneToOne>, response: Response<OneToOne>) {
                if (response.isSuccessful) {
                    Log.i(TAG, "onResponse Body => ${response.body()}")
                    response.body()?.apply {
                        if (this.data.isNullOrEmpty()) {
                            toast("내용이 없습니다.")
                            finish()
                        } else {
                            this.data.let {
                                mData = it[0]
                                binding.setVariable(BR.data, it[0])
                            }
                        }
                    }
                } else {
                    Log.e(TAG, "onResponse error => code:${response.code()}, ${response.body()}")
                }
            }
        })
    }

    private fun deleteMyQNA(id: Int) {
        Log.d(TAG, "deleteMyQNA => id:$id")
        RetrofitClient.getService().deleteMyQNA(id).enqueue(object : Callback<Void> {
            override fun onFailure(call: Call<Void>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Void>, response: Response<Void>) {
                if (response.isSuccessful) {
                    Log.i(TAG, "onResponse Body => ${response.body()}")
                } else Log.e(TAG, "onResponse error => code:${response.code()}, ${response.body()}")
            }
        })

    }


}