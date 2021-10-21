package com.gongmanse.app.fragments

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import com.gongmanse.app.R
import com.gongmanse.app.utils.Constants


class IntroFragment : Fragment() {

    val page = arrayOf(
          R.mipmap.gongmanse_manual01, R.mipmap.gongmanse_manual02, R.mipmap.gongmanse_manual03, R.mipmap.gongmanse_manual04
        , R.mipmap.gongmanse_manual05, R.mipmap.gongmanse_manual06, R.mipmap.gongmanse_manual07, R.mipmap.gongmanse_manual08
    )

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_intro, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        arguments?.takeIf { it.containsKey(Constants.INTRO_POSITION) }?.apply {
            val imageView = view.findViewById<ImageView>(R.id.image_view)
            imageView.setImageResource(page[getInt(Constants.INTRO_POSITION)])
        }
    }

}