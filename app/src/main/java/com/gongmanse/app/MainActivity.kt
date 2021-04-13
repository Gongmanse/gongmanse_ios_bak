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
import androidx.navigation.NavDestination
import androidx.navigation.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import androidx.navigation.ui.setupWithNavController
import com.gongmanse.app.databinding.ActivityMainBinding
import com.gongmanse.app.feature.Intro.IntroActivity
import com.gongmanse.app.feature.main.MainFragmentDirections
import com.gongmanse.app.feature.splash.SplashActivity
import com.gongmanse.app.utils.Preferences
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity(), View.OnClickListener {

    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityMainBinding
    private lateinit var mAppBarConfiguration: AppBarConfiguration
    private lateinit var mActionbar: ActionBar
    private lateinit var mNavDestination: NavDestination
    private var mOptionsMenu: Menu? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.e(TAG, "onCreate to MainActivity")
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Intro or Splash
        showSplash()

        // Actionbar
        setSupportActionBar(binding.appBarLayout.toolbar)
        mActionbar = supportActionBar!!


        val navController = findNavController(R.id.nav_host_fragment)
        mAppBarConfiguration = AppBarConfiguration(navController.graph, binding.drawerLayout)
        setupActionBarWithNavController(navController, mAppBarConfiguration)
        nav_view.setupWithNavController(navController)

        val view = nav_view.getHeaderView(0)
        view.findViewById<Button>(R.id.btn_login).setOnClickListener(this)
        view.findViewById<Button>(R.id.btn_sign_up).setOnClickListener(this)

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

    override fun onClick(v: View?) {
        when(v?.id) {
            R.id.btn_login -> {
                nav_view.getHeaderView(0).let {
                    nav_view.removeHeaderView(it)
                    val view = nav_view.inflateHeaderView(R.layout.layout_login_header)
                    view.findViewById<Button>(R.id.btn_logout).setOnClickListener(this)
                    view.findViewById<Button>(R.id.btn_edit_profile).setOnClickListener(this)
                }
            }
            R.id.btn_logout -> {
                nav_view.getHeaderView(0).let {
                    nav_view.removeHeaderView(it)
                    val view = nav_view.inflateHeaderView(R.layout.layout_local_header)
                    view.findViewById<Button>(R.id.btn_login).setOnClickListener(this)
                    view.findViewById<Button>(R.id.btn_sign_up).setOnClickListener(this)
                }
            }
            R.id.btn_sign_up -> {

            }
            R.id.btn_edit_profile -> {

            }
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        val navController = findNavController(R.id.nav_host_fragment)
        return if (mNavDestination.id == R.id.mainFragment) {
            val direction = MainFragmentDirections.actionMainFragmentToMyNotificationFragment()
            navController.navigate(direction)
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

    private fun showSplash() {
        val intent = if (Preferences.first) {
            Intent(this, IntroActivity::class.java)
        } else {
            Intent(this, SplashActivity::class.java)
        }
        startActivity(intent) // Move loading view after create view
    }
}