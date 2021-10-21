package com.gongmanse.app.listeners

interface OnBottomSheetProgressListener {

    fun onSelectionUnit(key:String, id: Int?, jindo_title: String )

    fun onSelectionGrade(key:String, grades:String?, grade_title: String?, grade_num: Int?)


}
