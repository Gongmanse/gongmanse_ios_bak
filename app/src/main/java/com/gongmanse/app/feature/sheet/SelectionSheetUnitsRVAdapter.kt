package com.gongmanse.app.feature.sheet

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.data.model.sheet.Units
import com.gongmanse.app.databinding.ItemUnitsBinding
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.listeners.OnBottomSheetToUnitListener

class SelectionSheetUnitsRVAdapter(private val listener: OnBottomSheetToUnitListener) :
    RecyclerView.Adapter<SelectionSheetUnitsRVAdapter.ViewHolder>() {

    companion object {
        private val TAG = SelectionSheetUnitsRVAdapter::class.java.simpleName
    }

    private val items: ArrayList<Units> = ArrayList()
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
            bind(item, View.OnClickListener {

            })
        }
    }

    override fun getItemCount(): Int = items.size

    inner class ViewHolder(private val binding: ItemUnitsBinding) :
        RecyclerView.ViewHolder(binding.root) {
        fun bind(data: Units, listener: View.OnClickListener) {
            binding.apply {
                this.data = data
                layoutUnits.setOnClickListener(listener)
            }
        }
    }

    fun addItem(newItem: Units) {
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
//            positions = items.withIndex().filter { it.value.units.toString() == selectUnit }.map { it.index }.first()
            positions
        }
    }

    fun setCurrent(currentPosition: Int) {
        Log.v(TAG,"position => $currentPosition")
        // xml -> isCurrent = true
        // ImgView Visibility, TextView Change Color
//        items[currentPosition].isCurrent = true
    }


}