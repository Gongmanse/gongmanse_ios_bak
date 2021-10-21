package com.gongmanse.app.activities

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.R
import com.gongmanse.app.adapter.counsel.CounselVPAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityCounselDetailBinding
import com.gongmanse.app.model.CounselData
import com.gongmanse.app.model.Media
import com.gongmanse.app.utils.Constants
import kotlinx.android.synthetic.main.layout_actionbar.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class CounselDetailActivity : AppCompatActivity() {

    companion object {
        private val TAG = CounselDetailActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityCounselDetailBinding
    private var item: CounselData? = null
    private val mSliderAdapter by lazy { CounselVPAdapter() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_counsel_detail)
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_COUNSEL
        binding.layoutEmpty.title = Constants.TEXT_VIEW_IMAGE_EMPTY

        initData()
        initView()

        setVPLayout()

    }

    private fun initData() {
        if (intent.hasExtra(Constants.EXTRA_KEY_COUNSEL)) {
            item = intent.getSerializableExtra(Constants.EXTRA_KEY_COUNSEL) as CounselData
            binding.data = item
            Log.d(TAG,"$item")
        }
        if (item?.consultation_id != null) loadMedia(Constants.RESPONSE_KEY_COUNSEL_ID)
        else loadMedia(Constants.RESPONSE_KEY_CU_ID)
    }

    private fun setVPLayout() {
        binding.vpMedia.apply {
            binding.vpMedia.adapter = mSliderAdapter
        }
    }

    private fun initView() {
        btn_close.setOnClickListener {
            finish()
        }
    }

    private fun loadMedia(type: String?){
        Log.d(TAG,"loadMedia Type => $type")
        var id: String?
        Constants.apply {
            id = when(type) {
                RESPONSE_KEY_COUNSEL_ID          -> item?.consultation_id
                RESPONSE_KEY_CU_ID               -> item?.cu_id
                else -> item?.consultation_id
            }
        }
        Log.d("아이디값 확인","$id")
            RetrofitClient.getService().getCounselMedia(id).enqueue(object:Callback<Media> {
                override fun onFailure(call: Call<Media>, t: Throwable) {
                    Log.e(TAG, "Failed API call with call : $call\nexception : $t")
                }
                override fun onResponse(call: Call<Media>, response: Response<Media>) {
                    if (response.isSuccessful) {
                        response.body()?.apply {
                            this.let {
                                Log.e(TAG, "onResponse => ${this.data}")
                                mSliderAdapter.addItems(it.data as List<String>)
                            }
                        }
                    } else Log.e(TAG,"Failed API code : ${response.code()}\n message : ${response.message()} body: ${response.body()}")
                }
            })
    }
}