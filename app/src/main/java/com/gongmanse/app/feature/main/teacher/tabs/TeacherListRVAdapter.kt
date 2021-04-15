package com.gongmanse.app.feature.main.teacher.tabs

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.recyclerview.widget.RecyclerView
import com.gongmanse.app.R
import com.gongmanse.app.data.model.video.VideoBody
import com.gongmanse.app.databinding.ItemVideoBinding

class TeacherListRVAdapter(val grade : String) : RecyclerView.Adapter<TeacherListRVAdapter.ViewHolder> () {


    private val items: ArrayList<VideoBody> = ArrayList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            DataBindingUtil.inflate(
                LayoutInflater.from(parent.context),
                R.layout.item_video,
                parent,
                false
            )
        )
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
//
//        holder.apply {
//            bind(item, View.OnClickListener {
//                val wifiState = IsWIFIConnected().check(holder.itemView.context)
//                itemView.context.apply {
//                    if (Preferences.token.isEmpty()) {
//                        alert(title = null, message = getString(R.string.content_text_toast_login)) {
//                            positiveButton(getString(R.string.content_button_positive)) {
//                                it.dismiss()
//                                startActivity(intentFor<LoginActivity>().singleTop())
//                            }
//                        }.show()
//                    } else {
//                        if (!Preferences.mobileData && !wifiState) {
//                            alert(
//                                title = null,
//                                message = " WIFI 를 연결하거나, 설정에서 모바일 데이터 사용을 허용해주세요"
//                            ) {
//                                positiveButton("설정") {
//                                    it.dismiss()
//                                    startActivity(intentFor<SettingActivity>().singleTop())
//                                }
//                                negativeButton("닫기") {
//                                    it.dismiss()
//                                }
//                            }.show()
//                        } else {
//                            if (item.seriesId != null) {
//                                Log.d("grade", "grade => $grade")
//                                val itemTeacher = Teacher(
//                                    id = item.seriesId.toInt(),
//                                    title = "${item.title}",
//                                    grade = grade,
//                                    teacherName = "${item.teacherName}",
//                                    subject = "${item.subject}",
//                                    subjectColor = "${item.subjectColor}",
//                                    thumbnail = "${item.thumbnail}"
//                                )
//                                startActivity(
//                                    intentFor<TeacherDetailActivity>(
//                                        "id" to item.seriesId,
//                                        "teacher" to itemTeacher,
//                                        "videoId" to item.videoId
//                                    ).singleTop()
//                                )
//                            } else if(item.id != null){
//                                Log.d("grade", "grade => $grade")
//                                val itemTeacher = Teacher(
//                                    id = item.id.toInt(),
//                                    title = "${item.title}",
//                                    grade = grade,
//                                    teacherName = "${item.teacherName}",
//                                    subject = "${item.subject}",
//                                    subjectColor = "${item.subjectColor}",
//                                    thumbnail = "${item.thumbnail}"
//                                )
//                                startActivity(
//                                    intentFor<TeacherDetailActivity>(
//                                        "id" to item.seriesId,
//                                        "teacher" to itemTeacher,
//                                        "videoId" to item.videoId
//                                    ).singleTop()
//                                )
//                            }
//                        }
//                    }
//                }
//            })
//        }
    }
//
    fun addItems(newItems: List<VideoBody>) {
        items.addAll(newItems)
        notifyDataSetChanged()
    }


    class ViewHolder (private val binding : ItemVideoBinding) : RecyclerView.ViewHolder(binding.root){
        fun bind(data : VideoBody, listener: View.OnClickListener){
            binding.apply {
                this.data = data
                itemView.setOnClickListener(listener)
            }
        }
    }

}