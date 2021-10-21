package com.gongmanse.app.adapter

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.text.Html
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.style.ClickableSpan
import android.util.Log
import android.view.View
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.*
import androidx.cardview.widget.CardView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.databinding.BindingAdapter
import androidx.databinding.ObservableArrayList
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.signature.ObjectKey
import com.gongmanse.app.R
import com.gongmanse.app.R.color.main_color
import com.gongmanse.app.adapter.active.*
import com.gongmanse.app.adapter.counsel.CounselListAdapter
import com.gongmanse.app.adapter.notice.EventRVAdapter
import com.gongmanse.app.adapter.notice.NoticeRVAdapter
import com.gongmanse.app.adapter.progress.ProgressDetailRVAdapter
import com.gongmanse.app.adapter.progress.ProgressRVAdapter
import com.gongmanse.app.adapter.progress.ProgressUnitRVAdapter
import com.gongmanse.app.adapter.search.*
import com.gongmanse.app.adapter.video.HashTagRVAdapter
import com.gongmanse.app.adapter.video.NoteCanvasRVAdapter
import com.gongmanse.app.adapter.video.QNAContentsRVAdapter
import com.gongmanse.app.model.*
import com.gongmanse.app.utils.Commons
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.CustomLabelView
import kotlinx.android.synthetic.main.custom_label_view.view.*
import java.text.SimpleDateFormat
import java.util.*


// App Version
@SuppressLint("SetTextI18n")
@BindingAdapter("bindAppVersion")
fun bindViewAppVersion(view: TextView, version: String?) {
    view.text = "버전 $version"
}

// PIP 썸네일
@BindingAdapter("bindBottomThumbnail" , "bindBottomPlayerPosition")
fun bindViewBottomThumbnail(view : ImageView, url : String?, position: Long?){
    if(url != null){
        position?.let {
            if (position == -1L) {
                view.setBackgroundColor(ContextCompat.getColor(view.context, R.color.black))
            } else {
                val bitmap = Commons.getWebVideoThumbnail(Uri.parse(url), it * 1000)
                if (bitmap != null) {
                    view.setImageBitmap(bitmap)
                }
            }
        }
    }
}

// 캘린더 날짜 데이터 바인딩
@SuppressLint("SetTextI18n", "SimpleDateFormat")
@BindingAdapter("bindScheduleAddDateText2")
fun bindViewScheduleAddDateText2(view: TextView, values: String?) {
    values?.let{
        val date = System.currentTimeMillis()
        val date2 = date + 600000
        val format = SimpleDateFormat(" HH:mm")
        view.text = it + format.format(date2)
    }
}
@SuppressLint("SetTextI18n", "SimpleDateFormat")
@BindingAdapter("bindScheduleAddDateText")
fun bindViewScheduleAddDateText(view: TextView, values: String?) {
    values?.let{
        val date = System.currentTimeMillis()
        val format = SimpleDateFormat(" HH:mm")
        view.text = it + format.format(date)
    }
}

// 캘린더 오늘 날짜 색 바인딩
@BindingAdapter("bindDateColor")
fun bindViewDateColor(view: TextView, value: String?) {
    val now : Long = System.currentTimeMillis()
    val date = Date(now)
    val curYearFormat = SimpleDateFormat("yyyy", Locale.KOREA)
    val curMonthFormat = SimpleDateFormat("MM", Locale.KOREA)
    val curDayFormat = SimpleDateFormat("dd", Locale.KOREA)
    val nowDate = "${curYearFormat.format(date)}-${curMonthFormat.format(date)}-${curDayFormat.format(
        date
    )}"
    if(value != "" && !value.isNullOrEmpty()) {
        if (value == nowDate) {
//            Log.d("binding", "value => $value nowDate => $nowDate")
            view.setTextColor(ContextCompat.getColor(view.context, R.color.white))
            view.setBackgroundResource(R.drawable.background_round_main_color)
        } else {
            view.setBackgroundResource(R.color.white)
            view.setTextColor(ContextCompat.getColor(view.context, R.color.date_color_num))
        }
    }else{
        view.setBackgroundResource(R.color.white)
        view.setTextColor(ContextCompat.getColor(view.context, R.color.date_color_num))
    }

}

// 캘린더 날짜 바인딩
@BindingAdapter("bindDateText")
fun bindViewDateText(view: TextView, value: String?) {
    if(value != ""){
        val temp = value!!.substring(8).toInt()
        view.setText(temp.toString())
    }else{
        view.setText(value)
    }
}

// 캘린더 요일 색 바인딩
@BindingAdapter("bindWeekColor")
fun bindViewWeekColor(view: TextView, value: String?) {
    value?.let{
        when(value){
            Constants.CONTENT_VALUE_SUN -> {
                view.setTextColor(ContextCompat.getColor(view.context, R.color.week_color_sun))
            }
            Constants.CONTENT_VALUE_SAT -> {
                view.setTextColor(ContextCompat.getColor(view.context, R.color.week_color_sat))
            }
            else -> {
                view.setTextColor(ContextCompat.getColor(view.context, R.color.black))
            }
        }
    }
}

// 비디오 바인딩
@BindingAdapter("bindVideo")
fun bindViewVideo(view: VideoView, value: String?) {
    when {
        value.isNullOrEmpty() -> {
            view.visibility = View.GONE
        }
        value.contains("file") -> {
            view.apply {
                setMediaController(MediaController(view.context))
                setVideoURI(Uri.parse("$value"))
                setOnPreparedListener { it.start() }
            }
        }
        else -> {
            view.apply {
                setMediaController(MediaController(view.context))
                setVideoURI(Uri.parse("${Constants.FILE_DOMAIN}/$value"))
                setOnPreparedListener { it.start() }
            }
        }
    }

}

@BindingAdapter("bindPosition")
fun bindViewPlayCount(view: TextView, position: Int?) {
    view.context.apply {
        Log.v("bindPosition", "position => $position")
        view.text = resources.getString(R.string.content_text_count, (position ?: 0) + 1)
    }
}

@BindingAdapter("bindTotalNum")
fun bindViewPlayTotalCount(view: TextView, totalNum: Int?) {
    view.context.apply {
        Log.v("bindTotalNum", "totalNum => $totalNum")
        view.text = resources.getString(R.string.content_text_count, totalNum)
    }
}

// 콤마 convert 공백
@BindingAdapter("bindCommaToBlank")
fun bindViewCommaToBlank(view: TextView, value: String?) {
    val regex = ","
    view.text = value?.replace(regex.toRegex(), " ")
}

// Setting Text of Jindo Grade Type
@BindingAdapter("bindGradeTextOfJindo")
fun bindViewGradeTextOfJindo(view: TextView, value: String?){
    if (value!!.isNotEmpty()) {
        value.let {
            when(value) {
                Constants.CONTENT_VALUE_ELEMENTARY -> view.text =
                    Constants.CONTENT_VALUE_ELEMENTARY_VIEW  // 초등 -> 초
                Constants.CONTENT_VALUE_MIDDLE -> view.text = Constants.CONTENT_VALUE_MIDDLE_VIEW      // 중등 -> 중
                Constants.CONTENT_VALUE_HIGH -> view.text = Constants.CONTENT_VALUE_HIGH_VIEW        // 고등 -> 고
            }
        }
    } else Log.e("bindView", " value is Null(Jindo Grade) ")
}

@BindingAdapter("bindGradeToFirst")
fun bindViewGradeToFirst(view: TextView, value: String?){
    value?.let {
        view.text = it.substring(0, 1)
    }
}

// Setting Info -> Subject
@BindingAdapter("bindSettingInfoSubject")
fun bindViewSettingInfoSubject(view: TextView, value: String?) {
    Log.d("bindView", "value of Setting Info => $value")
    when(value) {
        Constants.CONTENT_VALUE_ALL_GRADE_SERVER -> {
            view.text = Constants.CONTENT_VALUE_ALL_SUBJECT
        }
        null -> {
            view.text = Constants.CONTENT_VALUE_ALL_SUBJECT
        }
        else -> { view.text = value}
    }
}

// Setting Info -> Subject
@BindingAdapter("bindSettingInfoGrade")
fun bindViewSettingInfoGrade(view: TextView, value: String?) {
    Log.d("bindView", "value of Setting Info => $value")
    if (value.isNullOrBlank()) {
        Log.d("bindView", "Setting Info Grade Value is Null, $value")
        view.text = "모든 학년"
    }
    else {
        Log.d("bindView", "Setting Info Grade Value, $value")
        view.text = value
    }
}

// Type Cast
@BindingAdapter("bindKeywordsIdCast")
fun bindViewKeywordsTypeCast(view: TextView, value: Int?) {
    Log.d("bindView", "value cast to String => $value")
    if (value != null) {
        view.text = value.toString()
    } else Log.e("bindView", "value is Null")
}

// URL Image Binding
@BindingAdapter("bindProfileURL")
fun bindViewProfileURL(view: ImageView, value: String?) {
    Log.v("BindProfileURL", "::: value => $value")
    if (value == null) {
        view.setImageDrawable(ContextCompat.getDrawable(view.context, R.drawable.ic_id_off))
    } else {
        val requestOptions = RequestOptions().apply {
            override(300, 300)
            diskCacheStrategy(DiskCacheStrategy.NONE)
            skipMemoryCache(false)
            placeholder(R.drawable.ic_id_off)
            error(R.drawable.ic_id_off)
            centerCrop()
            circleCrop()
            signature(ObjectKey(System.currentTimeMillis()))
        }
        Glide.with(view.context)
            .load("${Constants.FILE_DOMAIN}/$value")
            .apply(requestOptions)
            .into(view)
    }
}

// URL Image Binding
@BindingAdapter("bindProfileURL2")
fun bindViewProfileURL2(view: ImageView, value: String?) {
    Log.v("BindProfileURL", "::: value => $value")
    if (value == null) {
        view.setImageDrawable(ContextCompat.getDrawable(view.context, R.drawable.ic_id_off))
    } else {
        val requestOptions = RequestOptions().apply {
            override(300, 300)
            error(R.drawable.ic_id_off)
            centerCrop()
            circleCrop()
        }
        Glide.with(view.context)
            .load("${Constants.FILE_DOMAIN}/$value")
            .apply(requestOptions)
            .into(view)
    }
}

// URL Image Binding
@BindingAdapter("bindURL")
fun bindViewURL(view: ImageView, value: String?) {
    Log.d("bindViewRUL", "Value:$value")
    value?.let {
        if(it.contains("file:///")){
            Glide.with(view.context)
                .load(it)
                .placeholder(R.drawable.ic_photo_24px)
                .into(view)
        }else{
            Glide.with(view.context)
                .load("${Constants.FILE_DOMAIN}/$it")
                .placeholder(R.drawable.ic_photo_24px)
                .into(view)
        }
    }
}

// URL Image Binding
@BindingAdapter("bindNoteURL")
fun bindViewNoteURL(view: ImageView, value: String?) {
    value?.let {
        Glide.with(view.context)
            .load("${Constants.FILE_DOMAIN}/$it")
            .into(view)
    }
}

@BindingAdapter("bindURLImage")
fun bindViewURLImage(view: ImageView, value: String?) {
    if(value != null){
        if (value.endsWith(".mp4")) {
            val options = RequestOptions()
            options.isMemoryCacheable
            Glide.with(view.context)
                .setDefaultRequestOptions(options)
                .load("${Constants.FILE_DOMAIN}/$value")
                .thumbnail(0.1f)
                .error(R.mipmap.ic_icon_logo)
                .into(view)
        } else {
            Glide.with(view.context)
                .load("${Constants.FILE_DOMAIN}/$value")
                .thumbnail(0.1f)
                .diskCacheStrategy(DiskCacheStrategy.RESOURCE)
                .error(R.mipmap.ic_icon_logo)
                .into(view)
        }
    } else view.setImageResource(R.mipmap.ic_icon_logo)
}

@BindingAdapter("bindURLTeacher")
fun bindViewURLTeacher(view: ImageView, value: String?) {
    value?.let {
        Glide.with(view.context)
            .load("${Constants.FILE_DOMAIN}/$it")
            .override(1018, 548)
            .thumbnail(0.1f)
            .diskCacheStrategy(DiskCacheStrategy.RESOURCE)
            .into(view)
    }
}

// Notice Image Binding
@BindingAdapter("bindImgTag")
fun bindViewImgTag(view: ImageView, value: String?) {
    if (value != null) {
        value.let {
            Glide.with(view.context)
                .load(it)
                .override(1018, 548)
                .thumbnail(0.1f)
                .diskCacheStrategy(DiskCacheStrategy.RESOURCE)
                .error(R.drawable.ic_alert)
                .into(view)
        }
    } else view.setImageResource(R.drawable.ic_alert)
}

// My Active Unit Type
@SuppressLint("SetTextI18n")
@BindingAdapter("bindUnit")
fun bindViewUnit(view: TextView, value: String?) {
    if (value != null && value.isNotEmpty()) {
        Constants.apply {
            view.text = when(value) {
                CONTENT_VALUE_ACTIVE_UNIT_ONE -> CONTENT_VALUE_ACTIVE_UNIT_ONE_VIEW
                CONTENT_VALUE_ACTIVE_UNIT_TWO -> CONTENT_VALUE_ACTIVE_UNIT_TWO_VIEW
                CONTENT_VALUE_ACTIVE_UNIT_TERM-> CONTENT_VALUE_ACTIVE_UNIT_TERM
                else-> value
            }
        }
    } else {
            Log.d("bindUnit", "=> null")
    }

}

@BindingAdapter("bindUnitColor")
fun bindViewUnitColor(view: CardView, value: String?) {
    value?.let {
        if (it == Constants.CONTENT_VALUE_ACTIVE_UNIT_TERM) view.setCardBackgroundColor(
            ContextCompat.getColor(
                view.context,
                R.color.term_color
            )
        )
        else view.setCardBackgroundColor(
            ContextCompat.getColor(
                view.context,
                R.color.term_other_than_color
            )
        )
    }
}

@BindingAdapter("bindUnitColor2")
fun bindViewUnitColor(view: CustomLabelView, value: String?) {
    value?.let {
        if (it == Constants.CONTENT_VALUE_ACTIVE_UNIT_TERM) {
            view.bg.setCardBackgroundColor(ContextCompat.getColor(view.context, R.color.term_color))
        } else {
            view.bg.setCardBackgroundColor(
                ContextCompat.getColor(
                    view.context,
                    R.color.term_other_than_color
                )
            )
        }
    }
}

@BindingAdapter("bindUnitText")
fun bindViewUnitText(view: TextView, value: String?) {
    value?.let {
        if (it == Constants.CONTENT_VALUE_ACTIVE_UNIT_TERM) view.text = value
        else view.text = if (value == "1") "ⅰ" else "ⅱ"
    }
}

// Drawable Icon Binding
@BindingAdapter("bindDrawable")
fun bindViewDrawable(view: ImageView, value: Int?) {
    view.setImageDrawable(value?.let { ContextCompat.getDrawable(view.context, it) })
}

// UserType Binding
@BindingAdapter("bindUserType")
fun bindViewUserType(view: TextView, value: User?) {
    view.text = Commons.gradeToString(value)
}

// Notice Type
@BindingAdapter("bindNoticeEventType")
fun bindViewNoticeEventType(view: TextView, value: String?) {
    if (value != null) {
        when(value) {
            "Personal" -> {
                Log.d("bindView", "=> Personal is not define")
            }
            "Regular" -> {
                view.text = view.context.getString(R.string.content_setting_notice_type_event)
            }
            "Occasion" -> {
                view.text = view.context.getString(R.string.content_setting_notice_type_occasion)
            }
        }
    } else view.text = view.context.getString(R.string.content_setting_notice_type)
}

// Notice Event Status
@BindingAdapter("bindEventStatus")
fun bindViewEventStatus(view: TextView, value: Boolean?) {
    if (value != null) {
        (view.parent as CardView).visibility = View.VISIBLE
        when(value) {
            true -> {
                (view.parent as CardView).setCardBackgroundColor(
                    ContextCompat.getColor(
                        view.context,
                        R.color.dark_gray
                    )
                )
                view.text = Constants.OnToON_VALUE_STATUS_TRUE
            }
            false -> {
                (view.parent as CardView).setCardBackgroundColor(
                    ContextCompat.getColor(
                        view.context,
                        main_color
                    )
                )
                view.text = Constants.OnToON_VALUE_STATUS_FALSE
            }
        }
    } else {
        (view.parent as CardView).visibility = View.GONE
        Log.e("bindEventStatus", " is null")
    }
}

// Btn Change Color
@BindingAdapter("bindBtnChangeColor")
fun bindViewBtnChangeColor(view: TextView, value: Boolean?) {
    if (value != null) {
        if (value) (view.parent as CardView).setCardBackgroundColor(
            ContextCompat.getColor(
                view.context,
                main_color
            )
        )
        else (view.parent as CardView).setCardBackgroundColor(
            ContextCompat.getColor(
                view.context,
                R.color.dark_gray
            )
        )
    } else Log.e("bindBtn", " ChangeColorStatus is null")

}

// On To One Status
@BindingAdapter("bindOneStatus")
fun bindViewOnToOnStatus(view: TextView, value: Boolean?) {
    Log.e("bindOneStatus =>", "$value")
    if (value != null) {
        when(value) {
            true -> {
                (view.parent as CardView).setCardBackgroundColor(
                    ContextCompat.getColor(
                        view.context,
                        main_color
                    )
                )
                view.text = Constants.OnToON_VALUE_STATUS_TRUE

            }
            false -> {
                (view.parent as CardView).setCardBackgroundColor(
                    ContextCompat.getColor(
                        view.context,
                        R.color.dark_gray
                    )
                )
                view.text = Constants.OnToON_VALUE_STATUS_FALSE
            }
        }
    } else Log.e("bindOneToOne", "is null")
}

// Purchase History Binding
@BindingAdapter("bindPurchaseHistory")
fun bindViewPurchaseHistory(view: RecyclerView, values: ObservableArrayList<PurchaseData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let { (mAdapter as PurchaseRVAdapter).addItems(it) }
    }
}

// Note Images Binding
@BindingAdapter("bindVideoNote")
fun bindViewVideoNote(view: RecyclerView, values: NoteCanvasData?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let {
            Log.d("TAG", it.notes.toString())
            it.notes?.let { it1 -> (mAdapter as NoteCanvasRVAdapter).addItems(it1) }
        }
    }
}

// RecentVideo List Binding
@BindingAdapter("bindRecentVideo")
fun bindViewRecentVideo(view: RecyclerView, values: ObservableArrayList<VideoData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let { (mAdapter as RecentVideoRVAdapter).addItems(it) }
    }
}

// Note List Binding
@BindingAdapter("bindNote")
fun bindViewNote(view: RecyclerView, values: ObservableArrayList<VideoData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let { (mAdapter as NoteRVAdapter).addItems(it) }
    }
}

// QNA List Binding
@BindingAdapter("bindQNA")
fun bindViewQNA(view: RecyclerView, values: ObservableArrayList<QNAData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let { (mAdapter as QNARVAdapter).addItems(it) }
    }
}

// QNADetail List Binding
@BindingAdapter("bindQNADetail")
fun bindViewQNADetail(view: RecyclerView, values: ObservableArrayList<QNADetailData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let { (mAdapter as QNADetailRVAdapter).addItems(it) }
    }
}

// QNA Contents Binding
@BindingAdapter("bindQNAContents")
fun bindViewQNAContents(view: RecyclerView, values: ObservableArrayList<QNAData>?) {
    Log.e("bindQNAContents", "$values")
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let {
            (mAdapter as QNAContentsRVAdapter).apply {
                addItems(it)
            }
        }
    }
}
// PlayList Color Binding
@BindingAdapter("bindPlayListColor")
fun bindViewPlayListColor(view: ConstraintLayout, values: Boolean) {
    if(values){
        view.setBackgroundResource(R.color.gray)
    }else{
        view.setBackgroundResource(R.color.white)
    }

}
// PlayList Binding
@BindingAdapter("bindPlayList")
fun bindViewPlayList(view: RecyclerView, values: ObservableArrayList<VideoData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
//        values?.let { (mAdapter as PlayListRVAdapter).addItems(it) }
    }
}

// Question List Binding
@BindingAdapter("bindQuestion")
fun bindViewQuestion(view: RecyclerView, values: ObservableArrayList<CounselData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let { (mAdapter as QuestionRVAdapter).addItems(it) }
    }
}

// Favorite List Binding
@BindingAdapter("bindFavorite")
fun bindViewFavorite(view: RecyclerView, values: ObservableArrayList<VideoData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let { (mAdapter as FavoriteRVAdapter).addItems(it) }
    }
}

// Alarm List Binding
@BindingAdapter("bindAlarm")
fun bindViewAlarm(view: RecyclerView, values: ObservableArrayList<AlarmData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let { (mAdapter as AlarmRVAdapter).addItems(it) }
    }
}

// Hash Tag Binding
@BindingAdapter("bindHashTag")
fun bindViewNote(view: RecyclerView, value: String?) {
    Log.v("bindHashTag", "value => $value")
    val items = value?.split(",")
    view.adapter?.let {
        (it as HashTagRVAdapter).apply {
            clear()
            if (items != null) {
                addItems(items)
            }
        }
    }
}

// Hash Tag Binding
@BindingAdapter("bindStrHashTag")
fun bindViewNote(view: TextView, value: String?) {
    val ssb = SpannableStringBuilder(value)
    val items = value?.split(",")
    items?.forEach { tag ->
        val position = ssb.indexOf(tag)
        if (position != -1) {
            ssb.setSpan(object : ClickableSpan() {
                override fun onClick(widget: View) {
//                    val intent = Intent(view.context, SearchResultActivity::class.java).apply {
//                        putExtra(Constants.EXTRA_KEY_KEYWORD, item.substring(1))
//                        putExtra(Constants.EXTRA_KEY_VIDEO_URL, videoURL)
//                        putExtra(Constants.EXTRA_KEY_VIDEO_POSITION, playerPosition)
//                        putExtra(Constants.EXTRA_KEY_VIDEO_TITLE, videoTitle)
//                        putExtra(Constants.EXTRA_KEY_TEACHER_NAME, teacherName)
//                        putExtra(Constants.EXTRA_KEY_VIDEO_ID, context.mVideoViewModel.videoId.value)
//                        putExtra(Constants.EXTRA_KEY_BOTTOM_SERIES_ID, context.mVideoViewModel.seriesId.value)
//                        putExtra(Constants.EXTRA_KEY_BOTTOM_SUBJECT_ID, context.mVideoViewModel.subjectId.value)
//                        putExtra(Constants.EXTRA_KEY_BOTTOM_GRADE, context.mVideoViewModel.grade.value)
//                        putExtra(Constants.EXTRA_KEY_BOTTOM_SORTING, context.mVideoViewModel.sorting.value)
//                        putExtra(Constants.EXTRA_KEY_BOTTOM_KEYWORD, context.mVideoViewModel.keyword.value)
//                        putExtra(Constants.EXTRA_KEY_BOTTOM_QUERY_TYPE, context.mVideoViewModel.playListType.value)
//                        putExtra(Constants.EXTRA_KEY_BOTTOM_NOW_POSITION, context.mVideoViewModel.playListNowPosition.value)
//                    }

                }
            }, position, position.plus(tag.length), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        }
    }
    view.text = ssb
}


// Purchase History Binding
@BindingAdapter("bindPurchaseDuration")
fun bindViewPurchaseDuration(view: TextView, value: String?) {
    when (value) {
        Constants.PURCHASE_DURATION_30DAYS -> view.text =
            view.context.getString(R.string.content_button_pass_30days)
        Constants.PURCHASE_DURATION_90DAYS -> view.text =
            view.context.getString(R.string.content_button_pass_90days)
        Constants.PURCHASE_DURATION_150DAYS -> view.text =
            view.context.getString(R.string.content_button_pass_150days)
        Constants.PURCHASE_DURATION_365DAYS -> view.text =
            view.context.getString(R.string.content_button_pass_1years)
    }
}

// Progress List Binding
@BindingAdapter("bindProgress")
fun bindViewProgress(view: RecyclerView, values: ObservableArrayList<ProgressData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        values?.let { (mAdapter as ProgressRVAdapter).addItems(it) }
    }
}

// ProgressDetail Binding
@BindingAdapter("bindProgressDetail")
fun bindViewProgressDetail(view: RecyclerView, values: ObservableArrayList<VideoData>?) {
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        Log.d("bindProgressDetail", "=> $mAdapter")
        values?.let { (mAdapter as ProgressDetailRVAdapter).addItems(it) }
    }
}


// ProgressDetail Binding
@BindingAdapter("bindProgressUnit")
fun bindViewProgressUnit(view: RecyclerView, values: ObservableArrayList<ProgressData>?) {
    Log.d("bindProgressUnit", " In")
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        Log.d("bindProgressUnit", "=> $mAdapter")
        values?.let { (mAdapter as ProgressUnitRVAdapter).addItems(it) }
    }
}

// SearchHotList Binding
@BindingAdapter("bindSearchHotListData")
fun bindViewSearchHotListData(view: RecyclerView, values: ObservableArrayList<SearchHotListData>?) {
    Log.d("bindHotListData", " In")
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        Log.d("bindHotListData", "=> $mAdapter")
        values?.let { (mAdapter as SearchHotRVAdapter).addItems(it) }
    }
}

// Search Subject List Data Binding
@BindingAdapter("bindSearchSubjectListData")
fun bindViewSearchSubjectListData(
    view: RecyclerView,
    values: ObservableArrayList<SearchSubjectListData>?
) {
    Log.d("bindSearchSubjectData", " In")
    val mAdapter = view.adapter
    if (mAdapter != null ) {
        Log.d("bindSearchSubjectData", "=> $mAdapter")
        values?.let { (mAdapter as SearchSubjectRVAdapter).addItems(it) }
    }

}

// Search Video List Data Binding
@BindingAdapter("bindSearchVideoData")
fun bindViewSearchVideoListData(view: RecyclerView, values: ObservableArrayList<VideoData>?) {
    Log.d("bindSearchVideoData", " In")
    val mAdapter = view.adapter
    if (mAdapter != null ) {
        Log.d("bindSearchVideoData", "=> $mAdapter")
//        values?.let { (mAdapter as SearchVideoRVAdapter).addItems(it) }
        values?.let { (mAdapter as SearchVideoLoadingRVAdapter).addItems(it) }
    }
}

// Search Counsel List Data Binding
@BindingAdapter("bindSearchCounselData")
fun bindViewCounselListData(view: RecyclerView, values: ObservableArrayList<CounselData>?) {
    Log.d("bindSearchCounselData", " In")
    val mAdapter = view.adapter
    if (mAdapter != null) {
        Log.d("bindSearchCounselData", "=> $mAdapter")
        values?.let { (mAdapter as CounselListAdapter).addItems(it) }
    }

}

// ProgressDetail Binding
@BindingAdapter("bindSearchNoteData")
fun bindViewSearchNoteListData(view: RecyclerView, values: ObservableArrayList<VideoData>?) {
    Log.d("bindSearchNoticeData", " In")
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        Log.d("bindSearchNoticeData", "=> $mAdapter")
        values?.let { (mAdapter as SearchNoteRVAdapter).addItems(it) }
    }
}

// ProgressDetail Binding
@BindingAdapter("bindSearchRecentData")
fun bindViewSearchRecentData(view: RecyclerView, values: ObservableArrayList<SearchRecentListData>?) {
    Log.d("bindSearchRecentData", " In")
    val mAdapter = view.adapter
    if (mAdapter != null)  {
        Log.d("bindSearchRecentData", "=> $mAdapter")
        values?.let { (mAdapter as SearchRecentRVAdapter).addItems(it) }
    }
}


// Notice List Data Binding
@BindingAdapter("bindNoticeData")
fun bindViewNoticeListData(view: RecyclerView, values: ObservableArrayList<NoticeData>?) {
    Log.d("bindNoticeData", " In")
    val mAdapter = view.adapter
    if (mAdapter != null) {
        Log.d("bindNoticeData", "=> $mAdapter")
        values?.let { (mAdapter as NoticeRVAdapter).addItems(it) }
    }

}

// Event List Data Binding
@BindingAdapter("bindEventData")
fun bindViewEventListData(view: RecyclerView, values: ObservableArrayList<EventData>?) {
    Log.d("bindEventData", " In")
    val mAdapter = view.adapter
    if (mAdapter != null) {
        Log.d("bindEventData", "=> $mAdapter")
        values?.let { (mAdapter as EventRVAdapter).addItems(it) }
    }

}

// 1:1 QNA List Data Binding
@BindingAdapter("bindOneToOneData")
fun bindViewOneToOneListData(view: RecyclerView, values: ObservableArrayList<OneToOneData>?) {
    Log.d("bindOneToOneData", "In")
    val mAdapter = view.adapter
    if (mAdapter != null) {
        Log.d("bindOneToOneData", "=> $mAdapter")
        values?.let { (mAdapter as OneToOneRVAdapter).addItems(it) }
    }
}

// FAQ List Data Binding
@BindingAdapter("bindFAQData")
fun bindViewFAQListData(view: RecyclerView, value: ObservableArrayList<FAQData>?){
    Log.d("bindFAQData", " In")
    val mAdapter = view.adapter
    if (mAdapter != null) {
        Log.d("bindFAQData", "=> $mAdapter")
        value?.let { (mAdapter as FAQRVAdapter).addItems(it) }
    }

}

// to Date
@SuppressLint("SetTextI18n")
@BindingAdapter("bindToDate")
fun bindViewToDate(view: TextView, value: String?) {
    if (value == null) view.text = ""
    else {
        val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
        val date = format.parse(value)

        date?.apply {
            val time = Calendar.getInstance(Locale.KOREA).timeInMillis - this.time
            Log.d("bindToDate", "timeMillis => $time")
            when {
                time < Constants.MINUTES -> view.text = "${time/Constants.SECONDS}초 전"
                time < Constants.HOURS   -> view.text = "${time/Constants.MINUTES}분 전"
                time < Constants.DAYS    -> view.text = "${time/Constants.HOURS}시간 전"
                time < Constants.WEEKS   -> view.text = "${time/Constants.DAYS}일 전"
                time < Constants.MONTHS  -> view.text = "${time/Constants.WEEKS}주 전"
                time < Constants.YEARS   -> view.text = "${time/Constants.MONTHS}개월 전"
                else                     -> view.text = "${time/Constants.YEARS}년 전"
            }
        }
    }
}

// One TO One QNA Type
@BindingAdapter("bindOneToOneType")
fun bindViewOneToOneType(view: TextView, value: String?) {
    if (value == null) Log.e("bindViewOneToOne", "is null")
    else {
        when(value) {
            "1" -> {
                view.text = Constants.CONTENT_TYPE_HOW_USE
            }
            "2" -> {
                view.text = Constants.CONTENT_TYPE_SERVICE_ERROR
            }
            "3" -> {
                view.text = Constants.CONTENT_TYPE_PAYMENT
            }
            "4" -> {
                view.text = Constants.CONTENT_TYPE_OTHER_ASSISTANCE
            }
            "5" -> {
                view.text = Constants.CONTENT_TYPE_LECTURE_REQUEST
            }
            else ->{ Log.w("OneToOne", "is null Type")}
        }
    }
}


// Expire Date
@BindingAdapter("bindRemainingDays")
fun bindViewRemainingDays(view: TextView, value: String?) {
    if (value == null) view.text = view.context.getString(R.string.content_text_purchase_pass)
    else {
        val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
        val date = format.parse(value)
        date?.apply {
            if (date < Date()) view.text = view.context.getString(R.string.content_text_purchase_pass)
            else {
                val days = (date.time - System.currentTimeMillis()) / (24 * 60 * 60 * 1000)
                view.text = String.format(
                    view.context.resources.getString(
                        R.string.content_text_pass_remaining_days,
                        days
                    )
                )
            }
        }
    }
}

// Expire Date
@BindingAdapter("bindAddRemainingDays")
fun bindViewAddRemainingDays(view: TextView, value: String?) {
    if (value == null) view.text = view.context.getString(R.string.content_button_purchase_pass)
    else {
        val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
        val date = format.parse(value)
        date?.apply {
            if (date < Date()) view.text = view.context.getString(R.string.content_button_purchase_pass)
            else view.text = view.context.getString(R.string.content_button_extension_pass)
        }
    }
}

// Recent Search
@BindingAdapter("bindRecentSearchDate")
fun bindViewRecentSearchDate(view: TextView, value: String) {
    if (value.isEmpty()) view.text = view.context.getString(R.string.content_empty_search_recent)
    else {
        val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
        val date = format.parse(value)
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.KOREA)
        date?.apply {
            view.text = dateFormat.format(this)
        }
    }
}

// Notice date
@BindingAdapter("bindNoticeDate")
fun bindViewNoticeData(view: TextView, value: String?) {
    if (value != null) {
        val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
        val date = format.parse(value)
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.KOREA)
        date?.apply {
            view.text = dateFormat.format(this)
        }
    }
    else Log.e("bindNoticeDate", " is Null")
}

// Notice Data Time
@BindingAdapter("bindNoticeDateTime")
fun bindViewNoticeDateTime(view: TextView, value: String?) {
    if (value != null) {
        val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
        val date = format.parse(value)
        val dateFormat = SimpleDateFormat("a h:mm", Locale.KOREA)
        date?.apply {
            view.text = dateFormat.format(this)
        }
    }
    else Log.e("bindNoticeDateTime", " is Null")
}


// MarkUp Language Remove
@BindingAdapter("bindRemoveMarkUp")
fun bindViewRemoveMarkUp(view: TextView, value: String?) {
    Log.d("bindRemoveMarkUp", "=> $value")
    val regex1 = "<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>".toRegex()
    val regex2 = "\r|\n|&nbsp;".toRegex()
    if (value == null) view.text = view.context.getString(R.string.content_empty_question_str)
    else {
        view.text = value.replace(regex1, "").replace(regex2, "")
    }
}

// MarkUp Language Remove MyQNA
@BindingAdapter("bindRemoveMarkUpQNA")
fun bindViewRemoveMarkUpQNA(view: TextView, value: String?) {
    Log.d("bindRemoveMarkUp", "=> $value")
    val regex1 = "<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>".toRegex()
    val regex2 = "\r|\n|&nbsp;".toRegex()
    if (value == null) view.hint = view.context.getString(R.string.content_counsel_hint)
    else {
        view.text = value.replace(regex1, "").replace(regex2, "")
    }
}

@BindingAdapter("bindRemoveMarkUpCounsel")
fun bindViewRemoveMarkUpCounsel(view: TextView, value: String?) {
    Log.d("bindRemoveMarkUpCounsel", "=> $value")
    val regex1 = "<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>".toRegex()
    val regex2 = "\r|\n|&nbsp;".toRegex()
    val regex3 = "&quot;".toRegex()
    if (value == null) view.text = view.context.getString(R.string.content_counsel_no_answer)
    else {
        view.text = Html.fromHtml(value.replace(regex1, "").replace(regex2, "").replace(regex3, ""))
    }
}

@BindingAdapter("bindRemoveMarkUpQNA")
fun bindViewRemoveMarkUpQNA(view: CheckBox, value: String?) {
    Log.d("bindRemoveMarkUpCounsel", "=> $value")
    val regex1 = "<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>".toRegex()
    val regex2 = "\r|\n|&nbsp;".toRegex()
    val regex3 = "&quot;".toRegex()
    if (value == null) view.text = view.context.getString(R.string.content_counsel_no_answer)
    else {
        view.text = Html.fromHtml(value.replace(regex1, "").replace(regex2, "").replace(regex3, ""))
    }
}

@BindingAdapter("bindDrawableUserRate")
fun bindViewDrawableUserRate(view: TextView, value: String?) {
    if (value == null) {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_grade_off)
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
    } else {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_grade_on)
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
    }
}

@BindingAdapter("bindDrawableBookMark")
fun bindViewDrawableBookMark(view: TextView, value: Boolean) {
    if (!value) {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_favorite_off)
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
    } else {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_favorite_on)
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
    }
}

@BindingAdapter("bindHasCommentary")
fun bindViewHasCommentary(view: TextView, value: String?) {
    when (value) {
        null, "0" -> view.visibility = View.GONE
        else -> view.visibility = View.VISIBLE
    }
}

@BindingAdapter("webViewUrl")
fun loadWebViewUrl(view: WebView, url: String?) {
    /* 웹 세팅 작업하기*/
    view.settings.apply {
        javaScriptEnabled = true
        javaScriptCanOpenWindowsAutomatically = true // window.open()을 사용하기 위함
        allowFileAccessFromFileURLs = true
        saveFormData = false
        savePassword = false
        useWideViewPort = true // html 컨테츠가 웹뷰에 맞게
        setSupportMultipleWindows(true)
        layoutAlgorithm = WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING
    }

    view.apply {
        /* 리다이렉트 할 때 브라우저 열리는 것 방지*/
        webViewClient = WebViewClient()
//        webChromeClient = WebChromeClient()

        /* 웹 뷰 띄우기 */
        url?.let { loadUrl(it) }
    }
}

@BindingAdapter("labelColor")
fun getLabelColor(view: CustomLabelView, s: String?) {
    s?.let {
        view.bg.setCardBackgroundColor(
            Color.parseColor(
                view.context.resources.getString(
                    R.string.content_text_subject_color,
                    it
                )
            )
        )
    }
}

@BindingAdapter("labelText")
fun getLabelText(view: CustomLabelView, s: String?) {
    if (s.isNullOrEmpty()) {
        view.visibility = View.GONE
    } else {
        view.visibility = View.VISIBLE
        view.txt.text = when(s) {
            Constants.CONTENT_VALUE_ACTIVE_UNIT_ONE -> Constants.CONTENT_VALUE_ACTIVE_UNIT_ONE_VIEW
            Constants.CONTENT_VALUE_ACTIVE_UNIT_TWO -> Constants.CONTENT_VALUE_ACTIVE_UNIT_TWO_VIEW
            Constants.CONTENT_VALUE_ACTIVE_UNIT_TERM -> Constants.CONTENT_VALUE_ACTIVE_UNIT_TERM
            else-> s
        }
    }
}

@BindingAdapter("labelUnitColor")
fun getLabelUnitColor(view: CustomLabelView, s: String?) {
    s?.let {
        if (it == Constants.CONTENT_VALUE_ACTIVE_UNIT_TERM) view.bg.setCardBackgroundColor(
            ContextCompat.getColor(
                view.context,
                R.color.term_color
            )
        )
        else view.bg.setCardBackgroundColor(
            ContextCompat.getColor(
                view.context,
                R.color.term_other_than_color
            )
        )
    }
}

@BindingAdapter("bindRating", "bindUserRating")
fun bindViewRating(view: TextView, rating: String?, userRating: Boolean?) {
    if (userRating == true) {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_grade_on)
        view.setTextColor(ContextCompat.getColor(view.context, main_color))
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
    } else {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_grade_off)
        view.setTextColor(ContextCompat.getColor(view.context, R.color.light_black2))
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
    }
    view.text = rating ?: "0.0"
}

@BindingAdapter("bindRating40", "bindUserRating40")
fun bindViewRating40(view: TextView, rating: String?, userRating: Boolean?) {
    if (userRating == true) {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_grade_on_40dp)
        view.setTextColor(ContextCompat.getColor(view.context, main_color))
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
    } else {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_grade_off_40dp)
        view.setTextColor(ContextCompat.getColor(view.context, R.color.light_black2))
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
    }
    view.text = rating ?: "0.0"
}

@BindingAdapter("bindIsBookMark")
fun bindViewIsBookMark(view: TextView, isMarking: Boolean) {
    if (!isMarking) {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_favorite_off)
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
        view.setTextColor(ContextCompat.getColor(view.context, R.color.light_black2))
    } else {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_favorite_on)
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
        view.setTextColor(ContextCompat.getColor(view.context, main_color))
    }
}

@BindingAdapter("bindIsBookMark40")
fun bindViewIsBookMark40(view: TextView, isMarking: Boolean) {
    if (!isMarking) {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_favorite_off_40dp)
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
        view.setTextColor(ContextCompat.getColor(view.context, R.color.light_black2))
    } else {
        val img = ContextCompat.getDrawable(view.context, R.drawable.ic_favorite_on_40dp)
        view.setCompoundDrawablesWithIntrinsicBounds(null, img, null, null)
        view.setTextColor(ContextCompat.getColor(view.context, main_color))
    }
}

@BindingAdapter("playListVisible")
fun setPlayListVisible(view: ConstraintLayout, videoList: VideoList?) {
    Log.v("VideoPlayLilst1", "videoList => $videoList")
}

@BindingAdapter("alarmDate")
fun bindViewAlarmDate(view: TextView, dtCreated: String?) {
    dtCreated?.let { dt ->
        val format1 = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
        val format2 = SimpleDateFormat("yyyy-MM-dd", Locale.KOREA)
        val date = format1.parse(dt)
        date?.let {
            view.text = format2.format(it)
        }

    }
}

@BindingAdapter("alarmTime")
fun bindViewAlarmTime(view: TextView, dtCreated: String?) {
    dtCreated?.let { dt ->
        val format1 = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
        val format2 = SimpleDateFormat("a HH:mm", Locale.KOREA)
        val date = format1.parse(dt)
        date?.let {
            view.text = format2.format(it)
        }
    }
}