package com.gongmanse.app.activities

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.Gravity
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.ViewModelProvider
import com.gongmanse.app.R
import com.gongmanse.app.fragments.ContentFragment
import com.gongmanse.app.fragments.DrawerFragment
import com.gongmanse.app.listeners.OnFragmentInteractionListener
import com.gongmanse.app.model.ActionType
import com.gongmanse.app.model.NoteLiveDataModel
import com.gongmanse.app.model.VideoData
import com.gongmanse.app.utils.*
import kotlinx.android.synthetic.main.activity_main.*
import org.jetbrains.anko.*

class MainActivity : AppCompatActivity(), OnFragmentInteractionListener {

    companion object {
        private val TAG = MainActivity::class.java.simpleName
        lateinit var listData: NoteLiveDataModel
    }

    private var fragment: Fragment? = null
    private var ordSorFrag: Fragment? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        getDeepLink()
        initView(savedInstanceState)
    }
    override fun onResume() {
        super.onResume()
        VideoPlayerRecyclerView.isGuest = Preferences.token.isEmpty() || !Commons.hasExpire()
    }

    private fun getDeepLink() {
        val data = this.intent.data
        if (data != null && data.isHierarchical) {
            val uri = this.intent.dataString
            val qVideoId = data.getQueryParameter("vid")
            if (qVideoId.isNullOrBlank().not()) {
                if (qVideoId != null) {
                    goToBestView(qVideoId)
                }
            }
            Log.e("AAAAAAAAAAAAAAAAAAAAAA", "uri : $uri vid : $qVideoId")
        }

        val bundle = this.intent.extras
        if (bundle != null) {
            Log.d(TAG, "deepLink : ${bundle["deepLink"]}")
            if (bundle["deepLink"] != null) {
                Constants.payloadLink(this, bundle["deepLink"] as String?)
            } else {
                moveSplash()
            }
        } else {
            moveSplash()
        }

        Handler().postDelayed({
            cover_view.visibility = View.GONE
        }, 1500)
    }

    @Suppress("UNCHECKED_CAST")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if(requestCode == 9001){
            when(resultCode){
                VideoNoteActivity.RESPONSE_CODE -> {
                    Log.d(TAG,"getData => $data")
                    if(data!=null){
                        val items = data.getSerializableExtra(Constants.EXTRA_KEY_ITEMS) as ArrayList<VideoData>
                        val position = data.getIntExtra(Constants.EXTRA_KEY_POSITION,0)
                        val type = data.getIntExtra(Constants.EXTRA_KEY_TYPE,-1)
                        listData.updateValue(ActionType.CLEAR,items,position,type)
                        listData.updateValue(ActionType.SET,items,position,type)
                        Log.d(TAG,"getData2 => $items")
                        Log.d(TAG,"liveData => ${listData.currentValue.value}")
                    }
                }
            }
        }
    }

    @SuppressLint("RtlHardcoded")
    override fun openDrawer() {
        Log.d(TAG, "openDrawer()...")
        layout_drawer.openDrawer(Gravity.RIGHT)
    }

    override fun closeDrawer() {
        Log.d(TAG, "closeDrawer()...")
        layout_drawer.closeDrawers()
    }

    override fun onBackPressed() {
        finishAlert()
    }

    private fun initView(savedInstanceState: Bundle?) {
        val fm: FragmentManager = supportFragmentManager
        if (savedInstanceState == null) {
            fragment = ContentFragment.newInstance()
            val t = fm.beginTransaction()
            t.replace(R.id.content_frame, fragment as ContentFragment)
            t.commit()

            ordSorFrag = DrawerFragment.newInstance()
            val r = fm.beginTransaction()
            r.replace(R.id.drawer_frame, ordSorFrag as DrawerFragment)
            r.commit()
        } else {
            fragment = fm.findFragmentById(R.id.content_frame)
            ordSorFrag = fm.findFragmentById(R.id.drawer_frame)
        }

        listData = ViewModelProvider(this).get(NoteLiveDataModel::class.java)
    }

    private fun moveSplash() {
        val intent = if (Preferences.first) {
            Intent(this, IntroActivity::class.java)
        } else {
            Intent(this, SplashActivity::class.java)
        }
        startActivity(intent) // 화면 생성 후 로딩화면으로 이동
        overridePendingTransition(android.R.anim.fade_in, 0)
    }

    private fun finishAlert() {
        Log.v(TAG, "drawer2 => ${layout_drawer.isDrawerOpen(Gravity.RIGHT)}")
        if (layout_drawer.isDrawerOpen(Gravity.RIGHT)) {
            closeDrawer()
            return
        }
        val content = (fragment as ContentFragment)
        Log.v(TAG, "content => ${content.isCurrentHomeFragment()}")
        if (content.isCurrentHomeFragment().not()) {
            content.setCurrentHomeFragment()
            return
        }
        alert(message = "앱을 종료하시겠습니까?") {
            yesButton { finish() }
            noButton { it.dismiss() }
        }.show()
    }

    fun updateGradeAndSubject() {
        Log.e(TAG, "updateGradeAndSubject()")
        (fragment as ContentFragment).updateGradeAndSubject()
    }

    private fun goToBestView(videoId: String) {
        val wifiState = IsWIFIConnected().check(this)
        if (!Preferences.mobileData && !wifiState) {
            alert(
                title = null,
                message = " WIFI 를 연결하거나, 설정에서 모바일 데이터 사용을 허용해주세요"
            ) {
                positiveButton("설정") {
                    it.dismiss()
                    startActivity(intentFor<SettingActivity>().singleTop())
                }
                negativeButton("닫기") {
                    it.dismiss()
                }
            }.show()
        }else {
            if (Preferences.token.isEmpty()) {
                val intent = Intent(this, VideoActivity::class.java)
//                intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)
                intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, videoId)
                intent.putExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_BEST)
                startActivity(intent)
            } else {
                val intent = Intent(this, VideoActivity::class.java)
//                intent.putExtra(Constants.EXTRA_KEY_SERIES_ID, item.seriesId)
                intent.putExtra(Constants.EXTRA_KEY_VIDEO_ID, videoId)
                intent.putExtra(Constants.EXTRA_KEY_TYPE, Constants.QUERY_TYPE_BEST)
                startActivity(intent)
            }
        }
    }

    fun selectedFragment(): Fragment? {
        val content = (fragment as ContentFragment)
        return content.getCurrentFragment()
    }
}