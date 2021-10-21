package com.gongmanse.app.utils

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.util.Log
import com.gongmanse.app.R
import com.gongmanse.app.activities.LoginActivity
import com.gongmanse.app.activities.VideoActivity
import com.gongmanse.app.model.User
import com.gongmanse.app.model.VideoQuery
import org.jetbrains.anko.alert
import org.jetbrains.anko.intentFor
import org.jetbrains.anko.noButton
import org.jetbrains.anko.yesButton
import java.lang.RuntimeException
import java.text.SimpleDateFormat
import java.util.*
import java.util.regex.Pattern
import kotlin.collections.HashMap

class Commons {

    companion object {

        /* User eType */
        private const val USER_TYPE_SUPER_ADMIN  = "Super Admin"
        private const val USER_TYPE_ADMIN        = "Admin"
        private const val USER_TYPE_MEMBER       = "Member"
        private const val USER_TYPE_PROFESSIONAL = "Professional"

        fun gradeToString(user: User?): String {
            if (user == null) return "로그인하고 더많은 서비스를 누리세요."
            return when (user.eType) {
                USER_TYPE_SUPER_ADMIN -> "${user.sNickname}님은 관리자 회원입니다."
                USER_TYPE_ADMIN -> "${user.sNickname}님은 매니저 회원입니다."
                USER_TYPE_MEMBER -> "${user.sNickname}님은 일반 회원입니다."
                USER_TYPE_PROFESSIONAL -> "${user.sNickname}님은 숙련자 회원입니다."
                else -> "로그인하고 더많은 서비스를 누리세요."
            }
        }

        fun close(activity: Activity) {
            Log.d(activity.localClassName, "onClick => 닫기")
            activity.finish()
        }

        fun makePhoneNumber(phoneNumber: String): String? {
            val number = digitPhoneNumber(phoneNumber)
            val regex = "(\\d{3})(\\d{3,4})(\\d{4})"
            if(!Pattern.matches(regex, number)) return null
            return number.replace(regex.toRegex(), "$1-$2-$3")
        }

        fun digitPhoneNumber(phoneNumber: String): String {
            return phoneNumber.replace("[^\\d]".toRegex(), "")
        }

        fun goVideoViewWithBottomVideoInfo(context: Context,videoQuery: VideoQuery ,position : Int){
            context.apply {
                val intent = Intent(this, VideoActivity::class.java)
                intent.putExtra(Constants.EXTRA_KEY_VIDEO_QUERY, videoQuery)
                intent.putExtra("videoPosition" , position)
                Log.e("goVideoView" , " goVideoView => $videoQuery")
                startActivity(intent)
            }
        }

        fun goVideoView(context: Context, videoQuery: VideoQuery) {
            context.apply {
                val intent = Intent(this, VideoActivity::class.java)
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                intent.putExtra(Constants.EXTRA_KEY_VIDEO_QUERY, videoQuery)
                Log.e("goVideoView" , " goVideoView => $videoQuery")
                startActivity(intent)
            }
        }

        fun hasLogin(context: Context) {
            context.apply {
                if (Preferences.token.isEmpty()) {
                    alert(message = getString(R.string.content_text_toast_login)) {
                        noButton { it.dismiss() }
                        yesButton { startActivity(intentFor<LoginActivity>()) }
                    }.show()
                }
            }
        }

        fun updatePreferencesGrade(grade: String?) {
            Log.v("preferencesGrade", ":$grade")
            Preferences.grade = when(grade) {
                null -> {Constants.CONTENT_VALUE_ALL_GRADE}
                else -> {grade}
            }
        }

        fun updatePreferencesSubjectId(subject_id: Int) {
            Log.v("preferencesSubjectId", ":$subject_id")
            Preferences.subjectId = subject_id
        }

        fun updatePreferencesSubject(subject: String?) : String {
            Log.v("preferencesSubject", ":$subject")
            Preferences.subject = when(subject) {
                Constants.CONTENT_VALUE_ALL_GRADE_SERVER -> { Constants.CONTENT_VALUE_ALL_SUBJECT }
                ""   -> { Constants.CONTENT_VALUE_ALL_SUBJECT }
                null -> { Constants.CONTENT_VALUE_ALL_SUBJECT }
                else -> { subject }
            }
            return Preferences.subject
        }

        fun getWebVideoThumbnail(uri: Uri, position: Long): Bitmap? {
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(uri.toString(), HashMap<String, String>())
                return retriever.getFrameAtTime(position, MediaMetadataRetriever.OPTION_CLOSEST)
            } catch (e: IllegalAccessException) {
                e.printStackTrace()
            } catch (e: RuntimeException) {
                e.printStackTrace()
            } finally {
                try {
                    retriever.release()
                } catch (e: RuntimeException) {
                    e.printStackTrace()
                }
            }
            return null
        }

        fun checkGrade(grade: String?): String? {
            Constants.GradeType.apply {
                return when (grade?.get(0)) {
//                    All_VIEW        -> All_GRADE
                    ELEMENTARY_VIEW -> ELEMENTARY
                    MIDDLE_VIEW     -> MIDDLE
                    HIGH_VIEW       -> HIGH
                    else            -> null
                }
            }
        }

        fun checkGradeNum(grade: String?) : Int? {
            val regexInt = "[^0-9]".toRegex()
            Constants.GradeType.apply {
                return when (grade?.replace(regexInt, "")) {
                    VALUE_GRADE_STRING_NUM_FIRST  -> VALUE_GRADE_STRING_NUM_FIRST.toInt()
                    VALUE_GRADE_STRING_NUM_SECOND -> VALUE_GRADE_STRING_NUM_SECOND.toInt()
                    VALUE_GRADE_STRING_NUM_THIRD  -> VALUE_GRADE_STRING_NUM_THIRD.toInt()
                    VALUE_GRADE_STRING_NUM_FOURTH -> VALUE_GRADE_STRING_NUM_FOURTH.toInt()
                    VALUE_GRADE_STRING_NUM_FIFTH  -> VALUE_GRADE_STRING_NUM_FIFTH.toInt()
                    VALUE_GRADE_STRING_NUM_SIXTH  -> VALUE_GRADE_STRING_NUM_SIXTH.toInt()
                    else                          -> VALUE_GRADE_STRING_NUM_NULL.toInt()
                }
            }
        }

        // 정렬 문자열을 ID로 전환
        fun getSortToId(selectText: String) : Int {
            return when(selectText){
                // 평점
                Constants.CONTENT_VALUE_AVG -> Constants.CONTENT_RESPONSE_VALUE_AVG
                // 최신
                Constants.CONTENT_VALUE_LATEST -> Constants.CONTENT_RESPONSE_VALUE_LATEST
                // 이름
                Constants.CONTENT_VALUE_NAME -> Constants.CONTENT_RESPONSE_VALUE_NAME
                // 과목
                Constants.CONTENT_VALUE_SUBJECT -> Constants.CONTENT_RESPONSE_VALUE_SUBJECT
                // 조회순
                Constants.CONTENT_VALUE_VIEWS -> Constants.CONTENT_RESPONSE_VALUE_VIEWS
                // 관련순
                Constants.CONTENT_VALUE_RELEVANCE -> Constants.CONTENT_RESPONSE_VALUE_RELEVANCE
                // 답변순
                Constants.CONTENT_VALUE_ANSWER -> Constants.CONTENT_RESPONSE_VALUE_ANSWER
                // 예외
                else -> Constants.CONTENT_RESPONSE_VALUE_LATEST
            }
        }

        fun hasExpire(): Boolean {
            if (Preferences.expire.isEmpty()) return false
            Log.v("Commons", "Preferences.expire => ${Preferences.expire}")
            val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
            val date = format.parse(Preferences.expire)
            date?.apply {
                return date > Date()
            }
            return false
        }

    }

}