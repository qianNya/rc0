package com.rc0.unity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class Rc0UnityWidgetPlugin : FlutterPlugin {
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "rc0_unity_widget")
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isUnityAvailable" -> result.success(Rc0UnityPlayerProbe.isUnityPlayerLinked)
                "createView" -> result.success(System.currentTimeMillis().toInt())
                "sendCommand" -> result.success(null)
                "disposeView" -> result.success(null)
                else -> result.notImplemented()
            }
        }
        eventChannel = EventChannel(binding.binaryMessenger, "rc0_unity_widget/events")
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {}
            override fun onCancel(arguments: Any?) {}
        })
        binding.platformViewRegistry.registerViewFactory(
            "rc0-unity-view-android",
            Rc0UnityViewFactory(),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }
}

object Rc0UnityBridge {
    @JvmStatic
    fun sendToFlutter(json: String) {
        // Called from Unity C# on Android
    }
}

object Rc0UnityPlayerProbe {
    val isUnityPlayerLinked: Boolean
        get() = try {
            Class.forName("com.unity3d.player.UnityPlayer")
            true
        } catch (_: ClassNotFoundException) {
            false
        }
}
