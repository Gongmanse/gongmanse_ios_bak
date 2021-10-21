package com.gongmanse.app.model

import androidx.databinding.BaseObservable
import androidx.databinding.ObservableArrayList
import com.google.gson.annotations.SerializedName
import com.gongmanse.app.utils.Constants
import java.io.Serializable

data class Favorite (
    @SerializedName(Constants.RESPONSE_KEY_TOTAL_NUM) val totalNum: String?,
    @SerializedName(Constants.RESPONSE_KEY_DATA) val data: ObservableArrayList<FavoriteData>?
): BaseObservable(), Serializable

data class FavoriteData (
    @SerializedName(Constants.RESPONSE_KEY_ID) val id: String?,
    @SerializedName(Constants.RESPONSE_KEY_USER_ID) val userId: String?,
    @SerializedName(Constants.RESPONSE_KEY_VIDEO_ID) val videoId: String?,
    @SerializedName(Constants.RESPONSE_KEY_THUMBNAIL) val thumbnail: String?,
    @SerializedName(Constants.RESPONSE_KEY_SUBJECT) val subject: String?,
    @SerializedName(Constants.RESPONSE_KEY_SUBJECT_COLOR) val subjectColor: String?,
    @SerializedName(Constants.RESPONSE_KEY_TEACHER) val teacherName: String?,
    @SerializedName(Constants.RESPONSE_KEY_TITLE) val title: String?,
    @SerializedName(Constants.RESPONSE_KEY_RATE) val rate: String?,
    @SerializedName(Constants.RESPONSE_KEY_REGISTER_DATE) val dtRegister: String?
): BaseObservable(), Serializable

