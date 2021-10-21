package com.gongmanse.app.adapter.progress

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.databinding.ItemProgressGradeBinding
import com.gongmanse.app.listeners.OnBottomSheetProgressListener
import com.gongmanse.app.utils.Constants
import kotlinx.android.synthetic.main.item_progress_grade.view.*

class ProgressGradeRVAdapter( private val listener: OnBottomSheetProgressListener) : RecyclerView.Adapter<ProgressGradeRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = ProgressGradeRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<String> = ArrayList()
    private val itemsGrade: ArrayList<String> = ArrayList()
    private var positions:Int = 0
    private lateinit var currentViewHolder: ViewHolder

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): ProgressGradeRVAdapter.ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_progress_grade, parent, false
            )
        )

    }

    fun addItems(newItems: List<String>) {
        items.clear()
        Log.e(TAG, "addItems :: $newItems")
        items.addAll(newItems)
        notifyDataSetChanged()
    }

    fun checkGrade(checkItems : List<String>){
        itemsGrade.addAll(checkItems)
    }

    fun getPosition(selectText: String): Int {
        Log.e(TAG, "selectText => $selectText")
        return if (items.isEmpty())  {
            positions = 0
            positions
        } else {
            positions = items.withIndex().filter { it.value == selectText }.map { it.index }.first()
            positions
        }
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ProgressGradeRVAdapter.ViewHolder, position: Int) {
        val item = items[position]

        holder.apply {
            bind(item, View.OnClickListener {
                setSelectionGrade(item)
            })
        }
    }


    inner class ViewHolder(private val binding: ItemProgressGradeBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: String, listener: View.OnClickListener) {
            binding.apply {
//                this.grade = data
                layoutGrade.setOnClickListener(listener)
            }
        }
    }

    private fun setSelectionGrade(grade_title: String) {
        Log.d(TAG, "setSelectionGrade => $grade_title")
        when {
            itemsGrade.contains(grade_title) -> {
                when(grade_title) {
                    // 모든 학년
                    Constants.CONTENT_VALUE_ALL_GRADE         -> { updateGrade(null, grade_title, null)}

                    // 초, 중, 고
                    Constants.CONTENT_VALUE_ELEMENTARY        -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, grade_title, null)}
                    Constants.CONTENT_VALUE_MIDDLE            -> { updateGrade(Constants.CONTENT_VALUE_MIDDLE, grade_title, null)}
                    Constants.CONTENT_VALUE_HIGH              -> { updateGrade(Constants.CONTENT_VALUE_HIGH, grade_title, null)}

                    // 초등
                    Constants.CONTENT_VALUE_ELEMENTARY_first  -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, grade_title, 1) }
                    Constants.CONTENT_VALUE_ELEMENTARY_second -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, grade_title, 2) }
                    Constants.CONTENT_VALUE_ELEMENTARY_third  -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, grade_title, 3) }
                    Constants.CONTENT_VALUE_ELEMENTARY_fourth -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, grade_title, 4) }
                    Constants.CONTENT_VALUE_ELEMENTARY_fifth  -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, grade_title, 5) }
                    Constants.CONTENT_VALUE_ELEMENTARY_sixth  -> { updateGrade(Constants.CONTENT_VALUE_ELEMENTARY, grade_title, 6) }
                    // 중등
                    Constants.CONTENT_VALUE_MIDDLE_first      -> { updateGrade(Constants.CONTENT_VALUE_MIDDLE, grade_title, 1) }
                    Constants.CONTENT_VALUE_MIDDLE_second     -> { updateGrade(Constants.CONTENT_VALUE_MIDDLE, grade_title, 2) }
                    Constants.CONTENT_VALUE_MIDDLE_third      -> { updateGrade(Constants.CONTENT_VALUE_MIDDLE, grade_title, 3) }

                    // 고등
                    Constants.CONTENT_VALUE_HIGH_first        -> { updateGrade(Constants.CONTENT_VALUE_HIGH, grade_title, 1) }
                    Constants.CONTENT_VALUE_HIGH_second       -> { updateGrade(Constants.CONTENT_VALUE_HIGH, grade_title, 2) }
                    Constants.CONTENT_VALUE_HIGH_third        -> { updateGrade(Constants.CONTENT_VALUE_HIGH, grade_title, 3) }
                }
            }

            else -> { Log.e(TAG, "Grade Title is Null")}
        }


    }

    private fun updateGrade(grade: String?, grade_title:String?, grade_num: Int?) {
        Log.i(TAG, "grade:$grade, grade_title:$grade_title, grade_num:$grade_num")
        listener.onSelectionGrade("selectionGrade", grade, grade_title, grade_num)
    }

    private fun current(view: View, holder: ViewHolder) {
        if (::currentViewHolder.isInitialized) {
            currentViewHolder.itemView.iv_show_check.visibility = View.INVISIBLE
            currentViewHolder.itemView.tv_unit_title.setTextColor(ContextCompat.getColor(view.context, R.color.black))
        }
        currentViewHolder = holder
        currentViewHolder.itemView.iv_show_check.visibility = View.VISIBLE
        currentViewHolder.itemView.tv_unit_title.setTextColor(ContextCompat.getColor(view.context, R.color.main_color))
    }


}