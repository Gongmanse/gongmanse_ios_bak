package com.gongmanse.app.model

import java.io.Serializable

data class Current (
    val grade: String?,
    var isCurrent: Boolean = false
): Serializable