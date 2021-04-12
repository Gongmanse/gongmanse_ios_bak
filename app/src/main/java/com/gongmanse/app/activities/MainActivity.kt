package com.gongmanse.app.activities

import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import androidx.appcompat.app.ActionBar
import androidx.appcompat.app.ActionBarDrawerToggle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.view.GravityCompat
import androidx.navigation.NavController
import androidx.navigation.NavDestination
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.NavigationUI
import androidx.navigation.ui.setupWithNavController
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ActivityMainBinding
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    companion object {
        private val TAG = MainActivity::class.java.simpleName
    }

    private lateinit var binding: ActivityMainBinding
    private lateinit var mAppBarConfiguration: AppBarConfiguration
    private lateinit var mNavController: NavController
    private lateinit var mActionbar: ActionBar
    private lateinit var mNavDestination: NavDestination
    private var mMenu: Menu? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Actionbar
        setSupportActionBar(binding.toolbar)
        mActionbar = supportActionBar!!

        // Bottom Navigation
        mNavController = (supportFragmentManager.findFragmentById(R.id.host_fragment) as NavHostFragment).navController
        nav_view.setupWithNavController(mNavController)

        // Navigation Up Button
        mAppBarConfiguration = AppBarConfiguration(mNavController.graph, binding.drawerLayout)
//        binding.toolbar.setupWithNavController(mNavController, mAppBarConfiguration)

//        NavigationUI.setupWithNavController(binding.toolbar, mNavController, mAppBarConfiguration)
//        NavigationUI.setupActionBarWithNavController(this, mNavController, binding.drawerLayout)

        mNavController.addOnDestinationChangedListener { _, destination, _ ->
            mNavDestination = destination
            mActionbar.apply {
                setDisplayHomeAsUpEnabled(true)
                setDisplayShowTitleEnabled(false)
                if (destination.id == R.id.mainFragment) {
                    setHomeAsUpIndicator(R.drawable.ic_notification)
                    mMenu?.setGroupVisible(R.id.menu_group, true)
                    binding.toolbar.setPadding(10, 0, 0, 10)
                    binding.title = null
                } else {
                    setHomeAsUpIndicator(R.drawable.ic_left_arrow)
                    mMenu?.setGroupVisible(R.id.menu_group, false)
                    binding.toolbar.setPadding(10, 0, 0, 40)
                    binding.title = destination.label.toString()
                }
//                setHomeAsUpIndicator(if (destination.id == R.id.mainFragment) R.drawable.ic_notification else R.drawable.ic_left_arrow)
            }
        }

    }

    override fun onSupportNavigateUp(): Boolean {
        return if (mNavDestination.id == R.id.mainFragment) {
            Log.d(TAG, "알람입니다.")
            false
        } else {
            NavigationUI.navigateUp(mNavController, mAppBarConfiguration)
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        mMenu = menu
        menuInflater.inflate(R.menu.main_menu, mMenu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when(item.itemId) {
            android.R.id.home -> {
                Log.d(TAG, "onOptionsItemSelected => android.R.id.home")
            }
            R.id.action_navigation -> {
                binding.drawerLayout.openDrawer(GravityCompat.END)
            }
        }
        return super.onOptionsItemSelected(item)
    }
}