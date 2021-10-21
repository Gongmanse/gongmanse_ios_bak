package com.gongmanse.app.adapter.progress

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemProgressGradeBinding
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import com.gongmanse.app.model.Current
import com.gongmanse.app.utils.Constants

class ProgressGradeCurrentRVAdapter( private val listener: OnBottomSheetProgressListener) : RecyclerView.Adapter<ProgressGradeCurrentRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = ProgressGradeCurrentRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<Current> = ArrayList()
    private val itemsGrade: ArrayList<String> = ArrayList()
    private var positions:Int = 0

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_progress_grade, parent, false
            )
        )
    }

    override fun getItemCount(): Int  = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item, View.OnClickListener {
                setSelectionGrade(item)
            })
        }

    }

    inner class ViewHolder(private val binding: ItemProgressGradeBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(data: Current, listener: View.OnClickListener) {
            binding.apply {
                this.current = data
                layoutGrade.setOnClickListener(listener)
            }
        }
    }

    // 아이템 추가
    fun addItem(newItem: Current) {
        Log.v(TAG, "addItem :: $newItem")
        items.add(newItem)
        notifyDataSetChanged()
    }

    fun checkGrade(checkItems : List<String>){
        itemsGrade.addAll(checkItems)
    }

    fun getPosition(selectText: String?): Int {
        Log.v(TAG, "selectText => $selectText")
        return if (items.isEmpty())  {
            positions = 0
            positions
        } else {
            positions = items.withIndex().filter { it.value.grade.toString() == selectText }.map { it.index }.first()
            positions
        }
    }

    fun setCurrent(currentPosition: Int) {
        Log.v(TAG,"position => $currentPosition")
        // xml -> isCurrent = true
        // ImgView Visibility, TextView Change Color
        items[currentPosition].isCurrent = true
    }

    private fun setSelectionGrade(current: Current) {
        val gradeTitle = current.grade
        Log.d(TAG, "setSelectionGrade => $gradeTitle")
        Constants.apply {
            when {
                itemsGrade.contains(gradeTitle) -> {
                    when(gradeTitle) {
                        // 모든 학년
                        CONTENT_VALUE_ALL_GRADE         -> { updateGrade(null, gradeTitle, null)}

                        // 초, 중, 고
                        CONTENT_VALUE_ELEMENTARY        -> { updateGrade(CONTENT_VALUE_ELEMENTARY, gradeTitle, null)}
                        CONTENT_VALUE_MIDDLE            -> { updateGrade(CONTENT_VALUE_MIDDLE, gradeTitle, null)}
                        CONTENT_VALUE_HIGH              -> { updateGrade(CONTENT_VALUE_HIGH, gradeTitle, null)}

                        // 초등
                        CONTENT_VALUE_ELEMENTARY_first  -> { updateGrade(CONTENT_VALUE_ELEMENTARY, gradeTitle, CONTENT_VALUE_GRADE_NUM_FIRST) }
                        CONTENT_VALUE_ELEMENTARY_second -> { updateGrade(CONTENT_VALUE_ELEMENTARY, gradeTitle, CONTENT_VALUE_GRADE_NUM_SECOND) }
                        CONTENT_VALUE_ELEMENTARY_third  -> { updateGrade(CONTENT_VALUE_ELEMENTARY, gradeTitle, CONTENT_VALUE_GRADE_NUM_THIRD) }
                        CONTENT_VALUE_ELEMENTARY_fourth -> { updateGrade(CONTENT_VALUE_ELEMENTARY, gradeTitle, CONTENT_VALUE_GRADE_NUM_FOURTH) }
                        CONTENT_VALUE_ELEMENTARY_fifth  -> { updateGrade(CONTENT_VALUE_ELEMENTARY, gradeTitle, CONTENT_VALUE_GRADE_NUM_FIFTH) }
                        CONTENT_VALUE_ELEMENTARY_sixth  -> { updateGrade(CONTENT_VALUE_ELEMENTARY, gradeTitle, CONTENT_VALUE_GRADE_NUM_SIXTH) }

                        // 중등
                        CONTENT_VALUE_MIDDLE_first      -> { updateGrade(CONTENT_VALUE_MIDDLE, gradeTitle, CONTENT_VALUE_GRADE_NUM_FIRST) }
                        CONTENT_VALUE_MIDDLE_second     -> { updateGrade(CONTENT_VALUE_MIDDLE, gradeTitle, CONTENT_VALUE_GRADE_NUM_SECOND) }
                        CONTENT_VALUE_MIDDLE_third      -> { updateGrade(CONTENT_VALUE_MIDDLE, gradeTitle, CONTENT_VALUE_GRADE_NUM_THIRD) }

                        // 고등
                        CONTENT_VALUE_HIGH_first        -> { updateGrade(CONTENT_VALUE_HIGH, gradeTitle, CONTENT_VALUE_GRADE_NUM_FIRST) }
                        CONTENT_VALUE_HIGH_second       -> { updateGrade(CONTENT_VALUE_HIGH, gradeTitle, CONTENT_VALUE_GRADE_NUM_SECOND) }
                        CONTENT_VALUE_HIGH_third        -> { updateGrade(CONTENT_VALUE_HIGH, gradeTitle, CONTENT_VALUE_GRADE_NUM_THIRD) }
                    }
                }

                else -> { Log.e(TAG, "Grade Title is Null")}
            }
        }
    }

    private fun updateGrade(grade: String?, grade_title:String?, grade_num: Int?) {
        Log.i(TAG, "grade:$grade, grade_title:$grade_title, grade_num:$grade_num")
        listener.onSelectionGrade("selectionGrade", grade, grade_title, grade_num)
    }


}