package com.gongmanse.app

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.ActionBar
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GravityCompat
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.observe
import androidx.navigation.NavDestination
import androidx.navigation.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import androidx.navigation.ui.setupWithNavController
import com.gongmanse.app.data.network.member.MemberRepository
import com.gongmanse.app.databinding.ActivityMainBinding
import com.gongmanse.app.databinding.LayoutLocalHeaderBinding
import com.gongmanse.app.databinding.LayoutLoginHeaderBinding
import com.gongmanse.app.feature.Intro.IntroActivity
import com.gongmanse.app.feature.main.MainFragmentDirections
import com.gongmanse.app.feature.member.LoginActivity
import com.gongmanse.app.feature.member.MemberViewModel
import com.gongmanse.app.feature.member.MemberViewModelFactory
import com.gongmanse.app.feature.splash.SplashActivity
import com.gongmanse.app.utils.Preferences
import kotlinx.android.synthetic.main.activity_main.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.jetbrains.anko.*

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
        bindUI()
    }

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.btn_login -> {
                val intent = Intent(this, LoginActivity::class.java)
                requestActivity.launch(intent)
            }
            R.id.btn_logout -> {
                alert(message = "로그아웃 하시겠습니까?") {
                    yesButton {
                        mMemberViewModel.logout()
                        it.dismiss()
                    }
                    noButton {
                        it.dismiss()
                    }
                }.show()
            }
            R.id.btn_sign_up -> {
                // TODO 회원가입 액티비티 생성
            }
            R.id.btn_edit_profile -> {
                // TODO 프로필 정보 수정 액티비티 생성
            }
            R.id.cv_purchase_ticket -> {
                // TODO 이용권 액티비티 생성
            }
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        val navController = findNavController(R.id.nav_host_fragment)
        return if (mNavDestination.id == R.id.mainFragment) {
            val direction = MainFragmentDirections.actionMainFragmentToMyNotificationFragment()
            navController.navigate(direction)
            binding.drawerLayout.closeDrawer(GravityCompat.END)
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

    private fun bindUI() {
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        CoroutineScope(Dispatchers.Main).launch {
            setupActionbar()
            setupNavigationController()
            setupMemberProfile()
        }
        showSplash()
    }

    private fun setupActionbar() {
        setSupportActionBar(binding.appBarLayout.toolbar)
        mActionbar = supportActionBar!!
    }

    private fun setupNavigationController() {
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

    private fun setupMemberProfile() {
        Log.w(TAG, "Preferences.token => ${Preferences.token}")
        if (::mMemberViewModelFactory.isInitialized.not()) {
            mMemberViewModelFactory = MemberViewModelFactory(MemberRepository())
        }
        if (::mMemberViewModel.isInitialized.not()) {
            mMemberViewModel = ViewModelProvider(this, mMemberViewModelFactory).get(MemberViewModel::class.java)
        }
        mMemberViewModel.getProfile()
        mMemberViewModel.currentMember.observe(this) {
            val navBinding = if (it != null) {
                DataBindingUtil.inflate<LayoutLoginHeaderBinding>(layoutInflater, R.layout.layout_login_header, binding.navView, false).apply {
                    btnLogout.setOnClickListener(this@MainActivity)
                    btnEditProfile.setOnClickListener(this@MainActivity)
                    cvPurchaseTicket.setOnClickListener(this@MainActivity)
                    member = it.memberBody
                }
            } else {
                DataBindingUtil.inflate<LayoutLocalHeaderBinding>(layoutInflater, R.layout.layout_local_header, binding.navView, false).apply {
                    btnLogin.setOnClickListener(this@MainActivity)
                    btnSignUp.setOnClickListener(this@MainActivity)
                }
            }
            binding.navView.apply {
                removeHeaderView(getHeaderView(0))
                addHeaderView(navBinding.root)
            }
        }
    }

    private fun showSplash() {
        val intent = if (Preferences.first) {
            Intent(this, IntroActivity::class.java)
        } else {
            Intent(this, SplashActivity::class.java)
        }
        startActivity(intent)
    }

    fun replaceBottomNavigation(title: String?) {
        binding.appBarLayout.title = title
    }

    private val requestActivity: ActivityResultLauncher<Intent> = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { activityResult ->
        if (activityResult.resultCode == Activity.RESULT_OK) {
            Log.d(TAG, "RequestActivity Login")
            setupMemberProfile()
        }
    }

}