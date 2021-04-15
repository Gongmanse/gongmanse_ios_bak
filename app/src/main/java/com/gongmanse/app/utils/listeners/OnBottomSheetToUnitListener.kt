package com.gongmanse.app.utils.listeners

interface OnBottomSheetToUnitListener {

    // 학년: Progress, Search, Setting 사용
    fun onSelectionGrade(grades: String?, grade_title: String, grade_num: Int?)

    // 단원: Progress 사용
    fun onSelectionUnit(id: Int?, title: String?)

    // 과목: Search, Setting 사용
    fun onSelectionSubject(id: Int?, subject: String?)

}