package com.gongmanse.app.activities

import android.Manifest
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.core.net.toFile
import androidx.databinding.DataBindingUtil
import androidx.viewpager2.widget.ViewPager2
import com.gun0912.tedpermission.PermissionListener
import com.gun0912.tedpermission.TedPermission
import com.rd.PageIndicatorView
import com.gongmanse.app.R
import com.gongmanse.app.adapter.counsel.CounselCreateRVAdapter
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.ActivityCounselCreateBinding
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.CustomDialog
import com.gongmanse.app.utils.Preferences
import com.google.gson.Gson
import gun0912.tedimagepicker.builder.TedImagePicker
import gun0912.tedimagepicker.builder.type.MediaType
import kotlinx.android.synthetic.main.layout_actionbar.*
import kotlinx.android.synthetic.main.layout_button.*
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.ResponseBody
import okhttp3.internal.notify
import okhttp3.internal.wait
import org.jetbrains.anko.alert
import org.jetbrains.anko.toast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.io.File
import java.io.FileOutputStream
import java.lang.NullPointerException

class CounselCreateActivity : AppCompatActivity() {

    companion object {
        private val TAG = CounselCreateActivity::class.java.simpleName
    }
    private lateinit var binding: ActivityCounselCreateBinding
    private lateinit var mRecyclerAdapter :CounselCreateRVAdapter
    private var type = ""
    private var fileList: ArrayList<Uri> = arrayListOf()
    private lateinit var pageIndicatorView :PageIndicatorView
    private var contents: String? = null
    private val media : ArrayList<String> = arrayListOf()
    private var index: Int =0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_counsel_create)

        initData()
        initView()

    }

    private fun initData(){
        imagePicker()
        checkPermission()
        confirmCheckContentListener()
    }
    private fun initView(){
        setInclude()
        setVPLayout()
    }

    private fun setVPLayout() {
        mRecyclerAdapter = CounselCreateRVAdapter(this)
        binding.vpMedia.apply {
            binding.vpMedia.adapter = mRecyclerAdapter
        }
        pageIndicatorView  = binding.pageIndicatorView
        pageIndicatorView.count = 0
        pageIndicatorView.selection = 0
        binding.vpMedia.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback(){
            override fun onPageSelected(position: Int) {
                pageIndicatorView.setSelected(position)
            }
        })
    }



    private fun setInclude(){
        binding.layoutToolbar.title = Constants.ACTIONBAR_TITLE_COUNSEL
        binding.layoutButton.btnText = Constants.BUTTON_TEXT_COUNSEL
        tv_btn.setOnClickListener {
            val stringBuffer = StringBuffer()
            contents = binding.etQuestion.text.toString()
            Log.d(TAG,"contents1 => $contents")
            if (!contents.isNullOrEmpty() ) {
                val contentList = contents?.split(System.getProperty("line.separator"))
                contentList?.forEach {
                    val str = "<p>$it</p> ${System.getProperty("line.separator")}${System.getProperty("line.separator")}"
                    stringBuffer.append(str)
                }
                Log.d(TAG,"contents2 => $stringBuffer")
            }
            contents = stringBuffer.toString()
            confirmCheckAndUpload()
        }
        btn_close.setOnClickListener {
            finish()
        }
    }

    private fun imagePicker() {
        binding.ivUploadBtn.setOnClickListener {
            if (mRecyclerAdapter.itemCount < 3) {
                Log.d("아이템 사이즈", "${mRecyclerAdapter.itemCount}")
                val dialog = CustomDialog(this)
                dialog.myDialog()
                dialog.setOnClickedListener(object: CustomDialog.ButtonClickListener {
                    override fun onClick(type: String) {
                        mediaPicker(type)
                    }
                })
            } else {
                toast("최대 3개까지만 가능합니다.")
            }
        }
    }

    private fun mediaPicker(mediaType : String) {

        if(mediaType == "IMAGE"){
            TedImagePicker.with(this@CounselCreateActivity).mediaType(MediaType.IMAGE).start {
                binding.progressBar2.visibility = View.VISIBLE
                GlobalScope.launch {
                    runBlocking {
                        this.launch{
                            runOnUiThread {
                                mRecyclerAdapter.addItems(it)
                                indicatorControl()
                                binding.progressBar2.visibility = View.GONE
                            }
                        }
                        getMediaSource(it)
                    }
                }
            }
        }else{
            TedImagePicker.with(this@CounselCreateActivity).mediaType(MediaType.VIDEO).start {
                binding.progressBar2.visibility = View.VISIBLE
                GlobalScope.launch {
                    runBlocking {
                        this.launch{
                            runOnUiThread {
                                mRecyclerAdapter.addItems(it)
                                indicatorControl()
                                binding.progressBar2.visibility = View.GONE
                            }
                        }
                        getMediaSource(it)
                    }
                }
            }
        }
    }

    fun deleteFile(position : Int){
        media.removeAt(position)
        indicatorControl()
    }


    private fun reSize(uri : Uri) {
        val requiredSize = 800
        val option = BitmapFactory.Options()
        option.inJustDecodeBounds = true
        val inputStream = binding.root.context.contentResolver.openInputStream(uri)
        BitmapFactory.decodeStream(inputStream,null,option)
        var width = option.outWidth
        var height = option.outHeight
        var scale = 1
        while(true){
            if(width/2 < requiredSize || height/2  < requiredSize  ){
                break
            }
            width/=2
            height/=2
            scale *=2
        }
        val option2 = BitmapFactory.Options()
        option2.inSampleSize = scale
    }
    fun indicatorControl(){
        if(mRecyclerAdapter.itemCount >= 1){
            pageIndicatorView.count = mRecyclerAdapter.itemCount
            binding.vpMedia.visibility = View.VISIBLE
            binding.pageIndicatorView.visibility = View.VISIBLE
            binding.ivDefault.visibility = View.GONE
            // 상단 갯수 출력 부분
            binding.tvMediaCount.text = mRecyclerAdapter.itemCount.toString()
        }else if(mRecyclerAdapter.itemCount == 0){
            pageIndicatorView.count = mRecyclerAdapter.itemCount
            binding.vpMedia.visibility = View.VISIBLE
            binding.pageIndicatorView.visibility = View.VISIBLE
            binding.ivDefault.visibility = View.GONE
            // 상단 갯수 출력 부분
            binding.tvMediaCount.text = mRecyclerAdapter.itemCount.toString()
        }

    }



    private fun checkPermission() {
    val permissionListener = object : PermissionListener {
        override fun onPermissionGranted() {
//            Toast.makeText(applicationContext, "Permission Granted", Toast.LENGTH_SHORT)
//                .show() // 권한 허가 toast
        }
        override fun onPermissionDenied(deniedPermissions: MutableList<String>?) {
            Toast.makeText(
                applicationContext,
                "Permission Denied\n" + deniedPermissions.toString(),
                Toast.LENGTH_SHORT
            ).show() // 권한 거부 toast
        }
    }
    TedPermission.with(this)
        .setPermissionListener(permissionListener) // 리스너 설정
        .setRationaleMessage("카메라 접근 권한 허용이 필요합니다.") // 권한이 필요한 이유
        .setDeniedMessage("거부되었습니다.\n[설정] > [권한]에서 권한을 허용할 수 있습니다.")
        .setPermissions(
            Manifest.permission.CAMERA,
            Manifest.permission.READ_EXTERNAL_STORAGE
        )
        .check() // 권한 체크 시작
    }


    private fun confirmCheckContentListener(){
        binding.etQuestion.addTextChangedListener(object : TextWatcher{
            override fun afterTextChanged(s: Editable?) {
                if(s.isNullOrEmpty()){
                    tv_btn.setBackgroundColor(ContextCompat.getColor(this@CounselCreateActivity,R.color.gray))
                }
            }
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                tv_btn.setBackgroundColor(ContextCompat.getColor(this@CounselCreateActivity,R.color.main_color))
            }
        })
    }
    private fun confirmCheckAndUpload(){
        if(contents.isNullOrEmpty()){
            Log.d(TAG,"contents3 => $contents")
            Toast.makeText(this, "내용을 작성해 주세요", Toast.LENGTH_SHORT).show()
        }else{
            alert(title = null, message = "전송 하시겠습니까?") {
                    positiveButton("확인") {
                        uploadCounsel()
                        it.dismiss()
                        finish()
                    }
                    negativeButton("취소") {
                        it.dismiss()
                    }
                }.show()
        }
    }

    private fun getMediaSource(uri: Uri) {
        val tokenForm = Preferences.token.toRequestBody("text/plain".toMediaTypeOrNull())
        val reqFile = uri.toFile().asRequestBody("multipart/form-data".toMediaTypeOrNull())
        val body = MultipartBody.Part.createFormData("file", uri.toFile().name, reqFile)
        val response = RetrofitClient.getServiceFile().uploadMedia(tokenForm, body).execute()
        response.body()?.let {it2 ->
            val str = it2.string()
            Log.d(TAG,"str => $str")
            Log.d("TAG","response  => ${it2.string()}")
            media.add(str)
        }
    }

    private fun uploadCounsel(){
        val arrayMedia : Array<String?> = arrayOf(null,null,null)
        for(i in 0 until media.size){
            arrayMedia[i] = media[i]
        }
        RetrofitClient.getService().uploadCounsel(Preferences.token,contents!!,arrayMedia[0],arrayMedia[1],arrayMedia[2]).enqueue( object : Callback<Map<String, Any>> {
            override fun onFailure(call: Call<Map<String, Any>>, t: Throwable) {
                Log.e(TAG, "Failed API call with call : $call\nexception : $t")
            }
            override fun onResponse(
                call: Call<Map<String, Any>>,
                response: Response<Map<String, Any>>
            ) {
                if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                if (response.isSuccessful) {
                    Log.d(TAG, "성공")
                }
            }
        })
    }
}