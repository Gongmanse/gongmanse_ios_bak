package com.gongmanse.app.model

import java.io.Serializable

data class NoteCanvas2 (
    val data: NoteCanvas2Data?
): Serializable

data class NoteCanvas2Data (
    val sNotes: List<String>?,
    val sJson: NoteCanvas2Json?
): Serializable

data class NoteCanvas2Json (
    val aspectRatio: String?,
    val strokes: List<NoteCanvas2Stroke>?
): Serializable

data class NoteCanvas2Stroke(
    val points: List<NoteCanvas2Point>?,
    val color: String? ,
    val cap: String?,
    val join: String?,
    val size: String?,
    val miterLimit: String?
): Serializable

data class NoteCanvas2Point (
    val x: String?,
    val y: String?
): Serializable