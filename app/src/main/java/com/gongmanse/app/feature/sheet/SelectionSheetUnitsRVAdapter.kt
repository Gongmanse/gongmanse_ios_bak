package com.gongmanse.app.feature.sheet

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.data.model.sheet.Units
import com.gongmanse.app.data.model.sheet.UnitsBody
import com.gongmanse.app.databinding.ItemUnitsBinding
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.listeners.OnBottomSheetToUnitListener

class SelectionSheetUnitsRVAdapter(private val listener: OnBottomSheetToUnitListener) :
    RecyclerView.Adapter<SelectionSheetUnitsRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = SelectionSheetUnitsRVAdapter::class.java.simpleName
    }

//    private val items: ArrayList<Units> = ArrayList()
    private val items: ArrayList<UnitsBody> = ArrayList()
    private var type: Int? = Constants.Init.INIT_INT
    private var positions: Int = Constants.Init.INIT_INT

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_units, parent, false
            )
        )
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.apply {
            bind(item, View.OnClickListener{
                updateUnits(item)
            })
        }
    }

    override fun getItemCount(): Int = items.size

    inner class ViewHolder(private val binding: ItemUnitsBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: UnitsBody, listener: View.OnClickListener) {
            binding.apply {
                this.data = data
                layoutUnits.setOnClickListener(listener)
            }
        }
    }

    fun addType(types: Int?) {
        type = types
    }

    fun addItem(newItem: UnitsBody) {
        Log.v(TAG, "addItem => $newItem")
        items.add(newItem)
        notifyDataSetChanged()
    }

    fun getPosition(selectUnit: String?): Int {
        Log.v(TAG, "selectText => $selectUnit")
        return if (items.isEmpty())  {
            positions = 0
            positions
        } else {
            positions = items.withIndex().filter { it.value.units.toString() == selectUnit }.map { it.index }.first()
            positions
        }
    }

    fun setCurrent(currentPosition: Int) {
        Log.v(TAG,"position => $currentPosition")
        // xml -> isCurrent = true
        // ImgView Visibility, TextView Change Color
        items[currentPosition].isCurrent = true
    }


    private fun updateUnits(unitsBody: UnitsBody) {
        Constants.SelectValue.apply {
            when(type) {
                SORT_ITEM_TYPE_GRADE   -> listener.onSelectionUnits(type, null, unitsBody.units)
                SORT_ITEM_TYPE_UNITS   -> listener.onSelectionUnits(type, unitsBody.id, unitsBody.units)
                SORT_ITEM_TYPE_SUBJECT -> listener.onSelectionUnits(type, unitsBody.id, unitsBody.units)
            }
        }
    }

}