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
import com.gongmanse.app.feature.main.EmptyFragmentDirections
import com.gongmanse.app.feature.main.MainFragment
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
                alert(resources.getString(R.string.alert_msg_logout)) {
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
                val action = EmptyFragmentDirections.actionEmptyFragmentToSignUpFragment()
                findNavController(R.id.nav_host_fragment).navigate(action)
                binding.drawerLayout.closeDrawer(GravityCompat.END)
            }
            R.id.btn_update_profile -> {
                val action = EmptyFragmentDirections.actionEmptyFragmentToUpdateProfileFragment()
                findNavController(R.id.nav_host_fragment).navigate(action)
                binding.drawerLayout.closeDrawer(GravityCompat.END)
            }
            R.id.cv_purchase_ticket -> {
                val action = EmptyFragmentDirections.actionEmptyFragmentToPurchaseTicketFragment()
                findNavController(R.id.nav_host_fragment).navigate(action)
                binding.drawerLayout.closeDrawer(GravityCompat.END)
            }
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        val navController = findNavController(R.id.nav_host_fragment)
        return if (mNavDestination.id == R.id.emptyFragment) {
            val action = EmptyFragmentDirections.actionEmptyFragmentToMyNotificationFragment()
            navController.navigate(action)
            binding.drawerLayout.closeDrawer(GravityCompat.END)
            false
        } else {
            val currentDestination = mNavDestination.id
            val result = navController.navigateUp(mAppBarConfiguration) || super.onSupportNavigateUp()
            if (currentDestination != R.id.myNotificationFragment) {
                binding.drawerLayout.openDrawer(GravityCompat.END)
            }
            result
        }
    }

    override fun onBackPressed() {
        alert(resources.getString(R.string.alert_msg_app_exit)) {
            yesButton {
                finish()
            }
            noButton {
                it.dismiss()
            }
        }.show()
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
            setupMainFragment()
            setupNavigationController()
            setupMemberProfile()
        }
        showSplash()
    }

    private fun setupActionbar() {
        setSupportActionBar(binding.appBarLayout.toolbar)
        mActionbar = supportActionBar!!
    }

    private fun setupMainFragment() {
        val transaction = supportFragmentManager.beginTransaction()
        transaction.replace(R.id.main_fragment, MainFragment()).commitAllowingStateLoss()
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
                if (destination.id == R.id.emptyFragment) {
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
        Log.v(TAG, "Preferences.token => ${Preferences.token}")
        if (::mMemberViewModelFactory.isInitialized.not()) {
            mMemberViewModelFactory = MemberViewModelFactory(MemberRepository())
        }
        if (::mMemberViewModel.isInitialized.not()) {
            mMemberViewModel = ViewModelProvider(this, mMemberViewModelFactory).get(MemberViewModel::class.java)
        }
        mMemberViewModel.getProfile()
        mMemberViewModel.currentMember.observe(this, {
            val navBinding = if (it != null) {
                DataBindingUtil.inflate<LayoutLoginHeaderBinding>(layoutInflater, R.layout.layout_login_header, binding.navView, false).apply {
                    btnLogout.setOnClickListener(this@MainActivity)
                    btnUpdateProfile.setOnClickListener(this@MainActivity)
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
        })
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
            setupMemberProfile()
        }
    }

    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }

}