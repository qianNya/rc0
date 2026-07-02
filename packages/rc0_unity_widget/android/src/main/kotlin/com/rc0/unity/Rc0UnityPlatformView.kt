package com.rc0.unity

import android.content.Context
import android.graphics.Color
import android.view.View
import io.flutter.plugin.platform.PlatformView

class Rc0UnityPlatformView(
    context: Context,
    private val viewId: Int,
    private val sessionId: String,
) : PlatformView {
    private val placeholder: View = View(context).apply {
        setBackgroundColor(Color.parseColor("#121018"))
    }

    override fun getView(): View = placeholder

    override fun dispose() {}
}
