package com.gongmanse.app.activities.customer

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.gongmanse.app.BR
import com.gongmanse.app.R
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityAddOneToOneBinding
import com.gongmanse.app.model.OneToOneData
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import kotlinx.android.synthetic.main.layout_button.*
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

@Suppress("DEPRECATION", "NULLABILITY_MISMATCH_BASED_ON_JAVA_ANNOTATIONS")
class AddOneToOneActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = AddOneToOneActivity::class.java.simpleName
        const val EDIT_RESPONSE_CODE = 1000
    }

    private lateinit var binding: ActivityAddOneToOneBinding
    private lateinit var data: OneToOneData
    private var qnaId: Int? = null
    private var categoryNumber: Int? = null
    private var contents: String? = null
    private var size:Int? = null
    private var edit: Boolean = false


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_add_one_to_one)
        initData()
        initView()
    }

    private fun confirmCheckContentListener() {
        binding.etQuestion.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) { btnChangeColor() }
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) { btnChangeColor() }
        })
    }

    private fun initData() {
        // 수정 일 경우의 data set 및 ed_text listener
        confirmCheckContentListener()
        if (intent.hasExtra(Constants.EXTRA_KEY_ONE_TO_ONE)) {
            intent.getSerializableExtra(Constants.EXTRA_KEY_ONE_TO_ONE).let {
                data = it as OneToOneData
                Log.i(TAG, "OneToOneData => $data")
                data.type?.let { type -> selectedCategory(type) }
                edit = true
                qnaId = data.id
                binding.layoutButton.btnText = resources.getString(R.string.content_button_edit_question)
                binding.setVariable(BR.data, data)
            }
        }
    }

    private fun initView() {
        Log.d(TAG,"initView()")
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_QNA
        binding.layoutToolbar.btnClose.setOnClickListener { onBackPressed() }
        binding.layoutButton.btnText = resources.getString(R.string.content_button_create)
        initData()
        size = binding.cgCategory.checkedChipIds.size
        contents = binding.etQuestion.text.toString()
        tv_btn.setOnClickListener {
            if (size == 1 && contents!!.isNotEmpty() ) {
                val stringBuffer = StringBuffer()
                val contentList = contents?.split(System.getProperty("line.separator"))
                contentList?.forEach {
                    val str = "<p>$it</p> ${System.getProperty("line.separator")}${System.getProperty("line.separator")}"
                    stringBuffer.append(str)
                }

                // 수정일 경우, 아닐 경우
                if (edit) categoryNumber?.let { categoryNumber -> editQNA(qnaId, stringBuffer.toString(), categoryNumber) } // 수정 일 경우
                else categoryNumber?.let { categoryNumber -> createQNA(stringBuffer.toString(), categoryNumber) }           // 수정 아닐 경우
            }
            else {
                if (size == 0) toast("카테고리를 선택해주세요.")
                else if (contents!!.isEmpty()) toast("내용을 입력해주세요.")
            } }

    }

    private fun selectedCategory(categoryType: String) {
        Log.d(TAG, "selectedCategory => $categoryType")
        binding.apply {
            when(categoryType) {
                "1" -> {
                    categoryNumber = 1
                    chipCategory1.isChecked = true
                }
                "2" -> {
                    categoryNumber = 2
                    chipCategory2.isChecked = true
                }
                "3" -> {
                    categoryNumber = 3
                    chipCategory3.isChecked = true
                }
                "4" -> {
                    categoryNumber = 4
                    chipCategory5.isChecked = true
                }
                "5" -> {
                    categoryNumber = 5
                    chipCategory4.isChecked = true
                }
            }
        }
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.chip_category1 -> {
                categoryNumber = 1
                btnChangeColor()
            }
            R.id.chip_category2 -> {
                categoryNumber = 2
                btnChangeColor()
            }
            R.id.chip_category3 -> {
                categoryNumber = 3
                btnChangeColor()
            }
            R.id.chip_category4 -> {
                categoryNumber = 5
                btnChangeColor()
            }
            R.id.chip_category5 -> {
                categoryNumber = 4
                btnChangeColor()
            }
        }
    }

    private fun btnChangeColor() {
        size = binding.cgCategory.checkedChipIds.size
        contents = binding.etQuestion.text.toString()
        binding.layoutButton.btnStatus = size == 1 && contents!!.isNotEmpty()
    }

    private fun createQNA(content: String?, type: Int) {
        Log.d(TAG, "createQNA: content:$content, type:$type")
        val regex1 = "\n".toRegex()
        content?.replace(regex1, "<br>")
        Log.e(TAG, "Value: $content")
        RetrofitClient.getService().registerQNA(Preferences.token, content, type).enqueue( object : Callback<Void> {
            override fun onFailure(call: Call<Void>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Void>, response: Response<Void>) {
                if (response.isSuccessful) {
                    Log.v(TAG,"Response is Successful => ${response.body()}")
                    onBackPressed()
                } else Log.e(TAG, "onResponse error => code:${response.code()}, ${response.body()}")
            }
        })
    }

    private fun editQNA(id: Int?, content: String?, type: Int) {
        Log.d(TAG, "editQNA id:$id, content:$content, type:$type")
        RetrofitClient.getService().editQNA(Preferences.token, id, content, type).enqueue( object : Callback<Void> {
            override fun onFailure(call: Call<Void>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }

            override fun onResponse(call: Call<Void>, response: Response<Void>) {
                if (response.isSuccessful) {
                    Log.v(TAG,"Response is Successful => ${response.body()}")
                    val intent = Intent()
                    intent.putExtra(Constants.EXTRA_KEY_QNA_ID, id)
                    setResult(EDIT_RESPONSE_CODE, intent)
                    finish()
                } else Log.e(TAG, "onResponse error => code:${response.code()}, ${response.body()}")
            }
        })

    }
}