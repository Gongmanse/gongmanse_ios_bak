package com.gongmanse.app.adapter

//class TabPagerAdapter(fm: FragmentManager): FragmentStatePagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {
//
//    private val fragments = ArrayList<Fragment>()
//
//    init {
//        fragments.add(ProgressKEMFragment())
//        fragments.add(ProgressScienceFragment())
//        fragments.add(ProgressSocietyFragment())
//        fragments.add(ProgressEtcFragment())
//    }
//
//    override fun getItem(position: Int): Fragment {
//        return fragments[position]
//    }
//
//    override fun getCount() = fragments.size
//
//    override fun getPageTitle(position: Int): CharSequence? {
//        return when (position) {
//            0 -> Constants.P_HOME_TAB_TITLE_KEM
//            1 -> Constants.P_HOME_TAB_TITLE_SCIENCE
//            2 -> Constants.P_HOME_TAB_TITLE_SOCIETY
//            3 -> Constants.P_HOME_TAB_TITLE_ETC
//            else -> null
//        }
//    }
//}