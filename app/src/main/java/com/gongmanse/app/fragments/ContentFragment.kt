package com.gongmanse.app.fragments

import android.content.Context
import android.os.Bundle
import android.util.Log
import android.view.*
import androidx.appcompat.app.ActionBar
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.os.bundleOf
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentTransaction
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.gongmanse.app.R
import com.gongmanse.app.activities.AlarmActivity
import com.gongmanse.app.activities.MainActivity
import com.gongmanse.app.databinding.FragmentContentBinding
import com.gongmanse.app.fragments.progress.ProgressFragment
import com.gongmanse.app.fragments.search.SearchMainFragment
import com.gongmanse.app.fragments.video.VideoQNASFragment
import com.gongmanse.app.listeners.OnFragmentInteractionListener
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import kotlinx.android.synthetic.main.fragment_content.*
import org.jetbrains.anko.singleTop
import org.jetbrains.anko.support.v4.intentFor

class ContentFragment : Fragment(), BottomNavigationView.OnNavigationItemSelectedListener {

    companion object {
        private val TAG = ContentFragment::class.java.simpleName

        fun newInstance() = ContentFragment().apply {
            arguments = bundleOf()
        }

    }

    private lateinit var binding: FragmentContentBinding
    private lateinit var actionbar: ActionBar
    private lateinit var homeFragment: HomeFragment
    private lateinit var progressFragment: ProgressFragment
    private lateinit var searchFragment: SearchMainFragment
    private lateinit var counselFragment: CounselFragment
    private lateinit var teacherFragment: TeacherFragment
    private var mListener: OnFragmentInteractionListener? = null
    private var selectFragment: Fragment? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        Log.v(TAG, "onAttach()...")
        mListener = if (context is OnFragmentInteractionListener) {
            context
        } else {
            throw RuntimeException("$context must implement OnFragmentInteractionListener")
        }
    }

    override fun onDetach() {
        super.onDetach()
        Log.v(TAG, "onDetach()...")
        mListener = null
    }

    //    fun putData(){
//        Log.e("제발 되라","ㅁㄴㅇㄻㄴㅇㄹ")
//        (activity as MainActivity).getResultData()
//    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_content, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        binding.bottomNavigation.setOnNavigationItemSelectedListener(this)
        setActionbar()
        setupFragment()
        replaceFragment(homeFragment)
    }

    private fun setActionbar() {
        setHasOptionsMenu(true)
        if (activity is AppCompatActivity) {
            (activity as AppCompatActivity).setSupportActionBar(binding.toolbar)
            actionbar = (activity as AppCompatActivity).supportActionBar!!
            actionbar.setDisplayShowTitleEnabled(false)
        }
        binding.toolbar.navigationIcon =
            ContextCompat.getDrawable(requireContext(), R.drawable.ic_alarm1)

    }

    // 화면 생성
    private fun setupFragment() {
        homeFragment = HomeFragment()
        progressFragment = ProgressFragment()
        searchFragment = SearchMainFragment()
        counselFragment = CounselFragment()
        teacherFragment = TeacherFragment()
        val fm: FragmentManager = (context as MainActivity).supportFragmentManager
        fm.beginTransaction()
            .add(R.id.layout_content, homeFragment)
            .hide(homeFragment)
            .add(R.id.layout_content, progressFragment)
            .hide(progressFragment)
            .add(R.id.layout_content, searchFragment)
            .hide(searchFragment)
            .add(R.id.layout_content, counselFragment)
            .hide(counselFragment)
            .add(R.id.layout_content, teacherFragment)
            .hide(teacherFragment)
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

    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        inflater.inflate(R.menu.content_main, menu)
        super.onCreateOptionsMenu(menu, inflater)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        Log.v(TAG, "onOptionsItemSelected() => ${item.itemId}")
        return when (item.itemId) {
            android.R.id.home -> {
                Log.v(TAG, "alarm selected...")
                startActivity(intentFor<AlarmActivity>().singleTop())
                true
            }
            R.id.action_drawer -> {
                Log.v(TAG, "drawer selected...")
                mListener?.openDrawer()
                true
            }

            else -> return super.onOptionsItemSelected(item)
        }
    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        Log.v(TAG, "onNavigationItemSelected() => ${item.itemId}")
        return when (item.itemId) {
            R.id.action_home -> {
                replaceFragment(homeFragment)
                binding.title = null
                true
            }
            R.id.action_progress -> {
                binding.title = Constants.ACTIONBAR_TITLE_JINDO
                replaceFragment(progressFragment)
                true
            }
            R.id.action_search -> {
                binding.title = Constants.ACTIONBAR_TITLE_SEARCH
                replaceFragment(searchFragment)
                true
            }
            R.id.action_counsel -> {
                binding.title = Constants.ACTIONBAR_TITLE_COUNSEL
                replaceFragment(counselFragment)
                true
            }
            R.id.action_teacher -> {
                binding.title = Constants.ACTIONBAR_TITLE_TEACHER
                replaceFragment(teacherFragment)
                true
            }
            else -> false
        }
    }

    fun updateGradeAndSubject() {
        Log.d(TAG, "updateGradeAndSubject()")
        progressFragment.updateGradeAndSubject()
        searchFragment.updateGradeAndSubject()
    }

    fun isCurrentHomeFragment(): Boolean {
        Log.v(TAG, "selectFragment => ${selectFragment?.javaClass?.simpleName}")
        Log.v(TAG, "homeFragment => ${homeFragment.javaClass.simpleName}")
        return selectFragment?.javaClass?.simpleName == homeFragment.javaClass.simpleName
    }

    fun setCurrentHomeFragment() {
        binding.bottomNavigation.selectedItemId = R.id.action_home
    }
}