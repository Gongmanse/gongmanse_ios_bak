package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class Note (
    @Expose @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<NoteData>?
): BaseObservable(), Serializable

data class NoteData (
    @Expose @SerializedName(Constants.RESPONSE_KEY_ID) val id: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUBJECT) val subject: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_SUBJECT_COLOR) val subjectColor: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TEACHER) val teacherName: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_TITLE) val title: String?,
    @Expose @SerializedName(Constants.RESPONSE_KEY_LAST_UPDATE) val dtUpdated: String?
): BaseObservable(), Serializable