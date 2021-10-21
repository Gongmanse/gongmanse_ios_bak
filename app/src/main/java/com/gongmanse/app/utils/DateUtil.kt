package com.gongmanse.app.utils

import java.text.SimpleDateFormat
import java.util.*

object DateUtil {
    const val CALENDAR_HEADER_FORMAT = "yyyy-MM-dd HH:mm:ss"
    const val YEAR_FORMAT = "yyyy"
    const val MONTH_FORMAT = "MM"
    const val DAY_FORMAT = "d"
    const val HOUR_FORMAT = "HH"
    const val MIN_FORMAT = "mm"
    const val SEC_FORMAT = "ss"
    fun getDate(date: Long, pattern: String?): String {
        return try {
            val formatter =
                SimpleDateFormat(pattern, Locale.KOREAN)
            val d = Date(date)
            formatter.format(d).toUpperCase()
        } catch (e: Exception) {
            " "
        }
    }
}