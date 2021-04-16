package com.gongmanse.app.feature.main

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentTransaction
import com.gongmanse.app.MainActivity
import com.gongmanse.app.R
import com.gongmanse.app.databinding.FragmentMainBinding
import com.gongmanse.app.feature.main.counsel.CounselFragment
import com.gongmanse.app.feature.main.home.HomeFragment
import com.gongmanse.app.feature.main.progress.ProgressFragment
import com.gongmanse.app.feature.main.teacher.TeacherFragment
import com.gongmanse.app.utils.Commons
import com.google.android.material.bottomnavigation.BottomNavigationView

class MainFragment : Fragment(), BottomNavigationView.OnNavigationItemSelectedListener {

    companion object {
        private val TAG = MainFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentMainBinding
    private lateinit var homeFragment: HomeFragment
    private lateinit var progressFragment: ProgressFragment
//    private lateinit var searchFragment: SearchMainFragment
    private lateinit var counselFragment: CounselFragment
    private lateinit var teacherFragment: TeacherFragment
    private var selectFragment: Fragment? = null

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMainBinding.inflate(inflater)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initView()
    }

    private fun initView() {
        Log.d(TAG, "MainFragment:: initView()")
        binding.bottomNavigation.setOnNavigationItemSelectedListener(this)
        setupFragment()
        replaceFragment(homeFragment)
    }

    // 화면 생성
    private fun setupFragment() {
        homeFragment = HomeFragment()
        teacherFragment = TeacherFragment()
        progressFragment = ProgressFragment()
        counselFragment = CounselFragment()
        val fm: FragmentManager = (activity as MainActivity).supportFragmentManager
        fm.beginTransaction()
            .add(R.id.content_layout, homeFragment)
            .hide(homeFragment)
            .add(R.id.content_layout, progressFragment)
            .hide(progressFragment)
//            .add(R.id.content_layout, searchFragment)
//            .hide(searchFragment)
            .add(R.id.content_layout, counselFragment)
            .hide(counselFragment)
            .add(R.id.content_layout, teacherFragment)
            .hide(teacherFragment)
            .commit()
    }

    // 화면 변경
    private fun replaceFragment(fragment: Fragment?) {
        Log.v(TAG, "replaceFragment() => ${fragment?.tag} / ${fragment?.javaClass?.name} / ${HomeFragment::class.java.name}")
        val fm: FragmentTransaction = (context as MainActivity).supportFragmentManager.beginTransaction()
        if (fragment != null) {
            selectFragment?.let { fm.hide(it) }
            (activity as MainActivity).apply {
                replaceBottomNavigation(Commons.findFragmentAppTitle(this, fragment.javaClass.simpleName))
            }
            fm.show(fragment)
            fm.addToBackStack(null)
            fm.commit()
            selectFragment = fragment
        }
    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        Log.v(TAG, "onNavigationItemSelected() => ${item.itemId}")
        return when (item.itemId) {
            R.id.action_home -> {
                replaceFragment(homeFragment)
                true
            }
            R.id.action_progress -> {
                replaceFragment(progressFragment)
                true
            }
            R.id.action_search -> {
//                replaceFragment(searchFragment)
                true
            }
            R.id.action_counsel -> {
                replaceFragment(counselFragment)
                true
            }
            R.id.action_teacher -> {
                replaceFragment(teacherFragment)
                true
            }
            else -> true
        }
    }

}