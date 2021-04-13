package com.gongmanse.app.feature.main

import android.os.Bundle
import android.util.Log
import android.view.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentTransaction
import com.gongmanse.app.MainActivity
import com.gongmanse.app.R
import com.gongmanse.app.databinding.FragmentMainBinding
import com.gongmanse.app.feature.main.home.HomeFragment
import com.google.android.material.bottomnavigation.BottomNavigationView
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.support.v4.intentFor


@Suppress("DEPRECATION")
class MainFragment : Fragment(), BottomNavigationView.OnNavigationItemSelectedListener {

    companion object {
        private val TAG = MainFragment::class.java.simpleName

        fun newInstance() = MainFragment().apply {
            arguments = bundleOf()
        }

    }

    private lateinit var binding: FragmentMainBinding
    private lateinit var homeFragment: HomeFragment
//    private lateinit var progressFragment: ProgressFragment
//    private lateinit var searchFragment: SearchMainFragment
//    private lateinit var counselFragment: CounselFragment
//    private lateinit var teacherFragment: TeacherFragment
//    private var mListener: OnFragmentInteractionListener? = null
    private var selectFragment: Fragment? = null

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentMainBinding.inflate(inflater)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }



    private fun initView() {
        binding.bottomNavigation.setOnNavigationItemSelectedListener(this)
        setupFragment()
        replaceFragment(homeFragment)
    }

    // 화면 생성
    private fun setupFragment() {
        homeFragment = HomeFragment()

        val fm: FragmentManager = (context as MainActivity).supportFragmentManager
        fm.beginTransaction()
            .add(R.id.content_layout, homeFragment)
            .hide(homeFragment)
            .commit()
    }

    // 화면 변경
    private fun replaceFragment(fragment: Fragment) {
        Log.v(TAG, "replaceFragment() => ${fragment.tag}")
        val fm: FragmentTransaction = (context as MainActivity).supportFragmentManager.beginTransaction()
        selectFragment?.let { fm.hide(it) }
        fm.show(fragment)
        fm.addToBackStack(null)
        fm.commit()
        selectFragment = fragment
    }



    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        Log.v(TAG, "onNavigationItemSelected() => ${item.itemId}")
        return when (item.itemId) {
            R.id.action_home -> {
                replaceFragment(homeFragment)
                true
            }
            else -> true
        }
    }



}