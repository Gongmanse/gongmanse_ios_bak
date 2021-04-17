package com.gongmanse.app.utils.listeners

interface OnBottomSheetToUnitListener {

//    // 학년: Progress, Search, Setting 사용
//    fun onSelectionGrade(grades: String?, grade_title: String, grade_num: Int?)
//
//    // 단원: Progress 사용
//    fun onSelectionUnit(id: Int?, title: String?)
//
//    // 과목: Search, Setting 사용
//    fun onSelectionSubject(id: Int?, subject: String?)

    /* 학년: id= grade_num units= grade_title, grade는 Index[0]번 체크로 초, 중, 고등 settings
     * 단원: id= 동일, units= title
     * 과목: id= 동일, units = subject
     */
    fun onSelectionUnits(id: Int?, units: String)

}