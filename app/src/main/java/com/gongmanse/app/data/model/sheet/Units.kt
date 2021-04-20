package com.gongmanse.app.data.model.sheet

import com.gongmanse.app.utils.Constants
import com.google.gson.annotations.SerializedName

data class Units(
    @SerializedName(Constants.Response.KEY_BODY) val unitsBody: ArrayList<UnitsBody>
)
