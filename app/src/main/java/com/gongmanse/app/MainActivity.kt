package com.gongmanse.app

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.Button
import androidx.appcompat.app.ActionBar
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GravityCompat
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.NavDestination
import androidx.navigation.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import androidx.navigation.ui.setupWithNavController
import com.gongmanse.app.data.network.member.MemberRepository
import com.gongmanse.app.databinding.ActivityMainBinding
import com.gongmanse.app.databinding.LayoutLoginHeaderBinding
import com.gongmanse.app.feature.Intro.IntroActivity
import com.gongmanse.app.feature.main.MainFragmentDirections
import com.gongmanse.app.feature.member.LoginActivity
import com.gongmanse.app.feature.member.MemberViewModel
import com.gongmanse.app.feature.member.MemberViewModelFactory
import com.gongmanse.app.feature.splash.SplashActivity
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import kotlinx.android.synthetic.main.activity_main.*
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.singleTop

class MainActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityMainBinding
    private lateinit var mAppBarConfiguration: AppBarConfiguration
    private lateinit var mActionbar: ActionBar
    private lateinit var mNavDestination: NavDestination
    private lateinit var mMemberViewModelFactory: MemberViewModelFactory
    private lateinit var mMemberViewModel: MemberViewModel

    private var mOptionsMenu: Menu? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.e(TAG, "onCreate to MainActivity")
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        showSplash()
        setActionbar()
        setNavigation()
        hasLogin()

    }

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.btn_login -> {
                startActivity(intentFor<LoginActivity>().singleTop())
            }
            R.id.btn_logout -> {
                // TODO 로그아웃 확인창 -> 로그아웃 (토큰 초기화)
            }
            R.id.btn_sign_up -> {
                // TODO 회원가입 액티비티 생성
            }
            R.id.btn_edit_profile -> {
                // TODO 프로필 정보 수정 액티비티 생성
            }
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        val navController = findNavController(R.id.nav_host_fragment)
        return if (mNavDestination.id == R.id.mainFragment) {
            actionNavigator(Constants.Action.VIEW_NOTIFICATION)
            false
        } else {
            navController.navigateUp(mAppBarConfiguration) || super.onSupportNavigateUp()
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        mOptionsMenu = menu
        menuInflater.inflate(R.menu.main_menu, mOptionsMenu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when(item.itemId) {
            R.id.action_navigation -> {
                binding.drawerLayout.openDrawer(GravityCompat.END)
            }
        }
        return super.onOptionsItemSelected(item)
    }

    private fun setActionbar() {
        setSupportActionBar(binding.appBarLayout.toolbar)
        mActionbar = supportActionBar!!
    }

    private fun setNavigation() {
        val navController = findNavController(R.id.nav_host_fragment)
        mAppBarConfiguration = AppBarConfiguration(navController.graph, binding.drawerLayout)
        setupActionBarWithNavController(navController, mAppBarConfiguration)
        nav_view.setupWithNavController(navController)

        navController.addOnDestinationChangedListener { _, destination, _ ->
            mNavDestination = destination
            mActionbar.apply {
                setDisplayHomeAsUpEnabled(true)
                setDisplayShowTitleEnabled(false)
                if (destination.id == R.id.mainFragment) {
                    setHomeAsUpIndicator(R.drawable.ic_notification)
                    mOptionsMenu?.setGroupVisible(R.id.menu_group, true)
                    binding.appBarLayout.title = null
                } else {
                    setHomeAsUpIndicator(R.drawable.ic_left_arrow)
                    mOptionsMenu?.setGroupVisible(R.id.menu_group, false)
                    binding.appBarLayout.title = destination.label.toString()
                }
            }
        }
    }

    private fun showSplash() {
        val intent = if (Preferences.first) {
            Intent(this, IntroActivity::class.java)
        } else {
            Intent(this, SplashActivity::class.java)
        }
        // Move loading view after create view
        startActivity(intent)
    }

    private fun actionNavigator(id: Int) {
        val navController = findNavController(R.id.nav_host_fragment)
        val direction = when(id) {
            Constants.Action.VIEW_NOTIFICATION -> MainFragmentDirections.actionMainFragmentToMyNotificationFragment()
            else -> MainFragmentDirections.actionMainFragmentToMyNotificationFragment()
        }
        navController.navigate(direction)
        drawer_layout.closeDrawer(GravityCompat.END)
    }

    private fun hasLogin() {
        mMemberViewModelFactory = MemberViewModelFactory(MemberRepository())
        mMemberViewModel = ViewModelProvider(this, mMemberViewModelFactory).get(MemberViewModel::class.java)
        Preferences.token = "NTMzMWY1YmEzZTJmYjJhOTk0NDQzM2VhMDc2NzBhYzAzNzJmNTJjMzU2MzM4YTViMjYzMmYzMTEyNWZmNGY1MDhmNGJmZDcwZjU0YmE0MGQ3OThhZTI5NTRmZDJmZmYyZTM5YTU1ZDMxMzIxNjA5YzJlM2FlMGUxZDczNWE5ZjArblJqTXZXZ2N1ek4wd0dWeFdYTVBxZkxWWDhZc3FMV2doT0YxOUpNK2pYWXlBV0EzL3prZG95cGpNTFRVM1YvTmlRR05iVXo0eXdhWEQ5ZUVJUmNQdz09"
        if (Preferences.token.isNotEmpty()) {
            nav_view.removeHeaderView(nav_view.getHeaderView(0))
            val navBinding = DataBindingUtil.inflate<LayoutLoginHeaderBinding>(layoutInflater, R.layout.layout_login_header, binding.navView, false)
            binding.navView.addHeaderView(navBinding.root)
            navBinding.btnLogout.setOnClickListener(this)
            navBinding.btnEditProfile.setOnClickListener(this)
            mMemberViewModel.getProfile()
            mMemberViewModel.currentValue.observe(this) {
                navBinding.member = it.memberBody
            }
        } else {
            nav_view.removeHeaderView(nav_view.getHeaderView(0))
            val view = nav_view.inflateHeaderView(R.layout.layout_local_header)
            view.findViewById<Button>(R.id.btn_login).setOnClickListener(this)
            view.findViewById<Button>(R.id.btn_sign_up).setOnClickListener(this)
        }
    }

    fun replaceBottomNavigation(title: String?) {
        binding.appBarLayout.title = title
    }

}