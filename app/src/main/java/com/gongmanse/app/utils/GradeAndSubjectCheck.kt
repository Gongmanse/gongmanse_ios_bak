package com.gongmanse.app.utils

import android.util.Log

class GradeAndSubjectCheck {

    companion object {

        val TAG: String = GradeAndSubjectCheck::class.java.simpleName

        fun checkSubjectList(subject: String) {
            Log.d(TAG, "loadSubjectList => $subject")
            Constants.apply {
                when(subject) {
                    SUBJECT_NAME_IS_KOREAN              -> {updatePreferencesSubjectId(1)}
                    SUBJECT_NAME_IS_ENGLISH             -> {updatePreferencesSubjectId(2)}
                    SUBJECT_NAME_IS_MATH                -> {updatePreferencesSubjectId(3)}
                    SUBJECT_NAME_IS_SOCIETY             -> {updatePreferencesSubjectId(4)}
                    SUBJECT_NAME_IS_HISTORY             -> {updatePreferencesSubjectId(5)}
                    SUBJECT_NAME_IS_SCIENCE             -> {updatePreferencesSubjectId(6)}
                    SUBJECT_NAME_IS_MUSIC               -> {updatePreferencesSubjectId(7)}
                    SUBJECT_NAME_IS_CHINESE_WRITING     -> {updatePreferencesSubjectId(8)}
                    SUBJECT_NAME_IS_TECHNOLOGY_HOME     -> {updatePreferencesSubjectId(9)}
                    SUBJECT_NAME_IS_PHYSICS             -> {updatePreferencesSubjectId(10)}
                    SUBJECT_NAME_IS_CHEMISTRY           -> {updatePreferencesSubjectId(11)}
                    SUBJECT_NAME_IS_LIFE_SCIENCE        -> {updatePreferencesSubjectId(12)}
                    SUBJECT_NAME_IS_EARTH_SCIENCE       -> {updatePreferencesSubjectId(13)}
                    SUBJECT_NAME_IS_LIFE_ETHICS         -> {updatePreferencesSubjectId(14)}
                    SUBJECT_NAME_IS_ETHICS_THOUGHT      -> {updatePreferencesSubjectId(15)}
                    SUBJECT_NAME_IS_KOREAN_GEOGRAPHY    -> {updatePreferencesSubjectId(16)}
                    SUBJECT_NAME_IS_WORLD_GEOGRAPHY     -> {updatePreferencesSubjectId(17)}
                    SUBJECT_NAME_IS_POLITICS_LAW        -> {updatePreferencesSubjectId(18)}
                    SUBJECT_NAME_IS_ECONOMY             -> {updatePreferencesSubjectId(19)}
                    SUBJECT_NAME_IS_SOCIAL_CULTURE      -> {updatePreferencesSubjectId(20)}
                    SUBJECT_NAME_IS_KOREAN_HISTORY      -> {updatePreferencesSubjectId(21)}
                    SUBJECT_NAME_IS_EAST_ASIA           -> {updatePreferencesSubjectId(22)}
                    SUBJECT_NAME_IS_WORLD_HISTORY       -> {updatePreferencesSubjectId(23)}
                    SUBJECT_NAME_IS_ESSAY               -> {updatePreferencesSubjectId(24)}
                    SUBJECT_NAME_IS_IDIOM               -> {updatePreferencesSubjectId(25)}
                    SUBJECT_NAME_IS_NON_LITERATURE      -> {updatePreferencesSubjectId(26)}
                    SUBJECT_NAME_IS_ENGLISH__VOCABULARY -> {updatePreferencesSubjectId(27)}
                    SUBJECT_NAME_IS_PASSING_EVENTS      -> {updatePreferencesSubjectId(28)}
                    SUBJECT_NAME_IS_INFORMATION         -> {updatePreferencesSubjectId(29)}
                    SUBJECT_NAME_IS_SPEECH_COMPOSITION  -> {updatePreferencesSubjectId(30)}
                    SUBJECT_NAME_IS_INTEGRATED_SCIENCE  -> {updatePreferencesSubjectId(31)}
                    SUBJECT_NAME_IS_MORALITY            -> {updatePreferencesSubjectId(32)}
                    SUBJECT_NAME_IS_UNIFIED_SOCIETY     -> {updatePreferencesSubjectId(33)}
                    CONTENT_VALUE_ALL_SUBJECT           -> {updatePreferencesSubjectId(38)} // 모든 과목, 전체
                    SUBJECT_NAME_IS_A_COMMON_SAYING     -> {updatePreferencesSubjectId(39)}
                }

            }

        }

        private fun updatePreferencesSubjectId(subject_id:Int) {
            Log.d(TAG,"updatePreferencesSubjectId:$subject_id")
            Commons.updatePreferencesSubjectId(subject_id)
        }

    }
}