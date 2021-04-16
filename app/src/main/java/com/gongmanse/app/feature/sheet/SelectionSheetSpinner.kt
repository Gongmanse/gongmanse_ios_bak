package com.gongmanse.app.feature.sheet

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.gongmanse.app.R
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.listeners.OnBottomSheetSpinnerListener
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import kotlinx.android.synthetic.main.dialog_sheet_selection_spinner.view.*

@Suppress("DEPRECATION")
class SelectionSheetSpinner(private val listener: OnBottomSheetSpinnerListener, private var selectText : String, private var type: Int?): BottomSheetDialogFragment() {

    companion object {
        private val TAG = SelectionSheetSpinner::class.java.simpleName
    }

    private lateinit var mContext: View

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        mContext = inflater.inflate(R.layout.dialog_sheet_selection_spinner, container, false)
        return mContext
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        setCheck()
        mContext.rootView.btn_close.setOnClickListener           { dismiss() }                                          // 닫기
        mContext.rootView.btn_show_avg.setOnClickListener        { updateSelection(Constants.SelectValue.SORT_AVG) }       // 평점
        mContext.rootView.btn_show_latest.setOnClickListener     { updateSelection(Constants.SelectValue.SORT_LATEST) }    // 최신순
        mContext.rootView.btn_show_name.setOnClickListener       { updateSelection(Constants.SelectValue.SORT_NAME) }      // 이름순
        mContext.rootView.btn_show_subject.setOnClickListener    { updateSelection(Constants.SelectValue.SORT_SUBJECT) }   // 과목순
        mContext.rootView.btn_show_views.setOnClickListener      { updateSelection(Constants.SelectValue.SORT_VIEWS) }     // 조회순
        mContext.rootView.btn_show_relevance.setOnClickListener  { updateSelection(Constants.SelectValue.SORT_RELEVANCE) } // 관련순
        mContext.rootView.btn_show_answer.setOnClickListener     { updateSelection(Constants.SelectValue.SORT_ANSWER) }    // 답변 완료순

    }

    // Set selected Text
    private fun updateSelection(string: String) {
        listener.selectedSortSpinnerValue(string)
        dismiss()
    }

    // Check Image Visibility
    @SuppressLint("ResourceAsColor")
    private fun setCheck(){
        when(type) {
            7 -> {
                mContext.apply {
                    btn_show_avg.visibility       = View.VISIBLE    // 평점순
                    btn_show_latest.visibility    = View.VISIBLE    // 최신순
                    divider2.visibility           = View.VISIBLE    // 최신순 위 구분선

                    btn_show_name.visibility      = View.VISIBLE    // 이름순
                    divider3.visibility           = View.VISIBLE    // 이름순 위 구분선

                    btn_show_subject.visibility   = View.VISIBLE    // 과목순
                    divider4.visibility           = View.VISIBLE    // 과목순 위 구분선

                    divider5.visibility           = View.GONE       // 조회순 위 구분선

                    btn_show_relevance.visibility = View.VISIBLE    // 관련순
                    divider7.visibility           = View.VISIBLE    // 관련순 위 구분선
                }
            }
            6 -> {
                mContext.apply {
                    btn_show_avg.visibility       = View.GONE       // 평점순
                    divider2.visibility           = View.GONE       // 최신순 위 구분선

                    btn_show_name.visibility      = View.GONE       // 이름순
                    divider3.visibility           = View.GONE       // 이름순 위 구분선

                    btn_show_subject.visibility   = View.GONE       // 과목순
                    divider4.visibility           = View.GONE       // 과목순 위 구분선

                    divider7.visibility           = View.GONE       // 관련순 위 구분선

                    btn_show_views.visibility     = View.VISIBLE    // 조회순
                    btn_show_answer.visibility    = View.VISIBLE    // 답변 완료순
                }
            }
            3 -> { }
        }


        when(selectText){
            /* 정렬 */
            // 평점
            Constants.SelectValue.SORT_AVG -> {
                mContext.rootView.iv_show_avg.visibility = View.VISIBLE
                selectText = Constants.SelectValue.SORT_AVG
                mContext.rootView.tv_show_avg.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            // 최신
            Constants.SelectValue.SORT_LATEST ->{
                mContext.iv_show_latest.visibility = View.VISIBLE
                selectText = Constants.SelectValue.SORT_LATEST
                mContext.tv_show_latest.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            // 이름
            Constants.SelectValue.SORT_NAME ->{
                mContext.iv_show_name.visibility = View.VISIBLE
                selectText = Constants.SelectValue.SORT_NAME
                mContext.rootView.tv_show_name.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            // 과목
            Constants.SelectValue.SORT_SUBJECT ->{
                mContext.iv_show_subject.visibility = View.VISIBLE
                selectText = Constants.SelectValue.SORT_SUBJECT
                mContext.rootView.tv_show_subject.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            // 조회순
            Constants.SelectValue.SORT_VIEWS -> {
                mContext.iv_show_views.visibility = View.VISIBLE
                selectText = Constants.SelectValue.SORT_VIEWS
                mContext.rootView.tv_show_views.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            Constants.SelectValue.SORT_RELEVANCE -> {
                mContext.iv_show_relevance.visibility = View.VISIBLE
                selectText = Constants.SelectValue.SORT_RELEVANCE
                mContext.rootView.tv_show_relevance.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
            // 답변순
            Constants.SelectValue.SORT_ANSWER -> {
                mContext.iv_show_answer.visibility = View.VISIBLE
                selectText = Constants.SelectValue.SORT_ANSWER
                mContext.rootView.tv_show_answer.setTextColor(ContextCompat.getColor(requireContext(), R.color.main_color))
            }
        }
    }

}