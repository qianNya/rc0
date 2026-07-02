package com.rc0.unity

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class Rc0UnityViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        val sessionId = params?.get("sessionId") as? String ?: "default"
        return Rc0UnityPlatformView(context, viewId, sessionId)
    }
}
