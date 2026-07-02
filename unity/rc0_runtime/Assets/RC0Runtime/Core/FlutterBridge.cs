using System;
using System.Collections.Generic;
using UnityEngine;

namespace RC0.Runtime.Core
{
    /// <summary>
    /// Receives JSON commands from Flutter and emits events back.
    /// Native: bound via rc0_unity_widget MethodChannel/EventChannel.
    /// WebGL: bound via jslib postMessage.
    /// </summary>
    public sealed class FlutterBridge : MonoBehaviour
    {
        public static FlutterBridge Instance { get; private set; }

        RuntimeBootstrap _bootstrap;
        Action<string> _emitToFlutter;

        public void Initialize(RuntimeBootstrap bootstrap, Action<string> emitToFlutter)
        {
            _bootstrap = bootstrap;
            _emitToFlutter = emitToFlutter;
            Instance = this;
        }

        public void OnFlutterMessage(string json)
        {
            if (string.IsNullOrEmpty(json) || _bootstrap == null) return;
            _bootstrap.HandleFlutterJson(json);
        }

        public void Emit(RuntimeEvent runtimeEvent)
        {
            if (_emitToFlutter == null || runtimeEvent == null) return;
            var json = RuntimeJson.SerializeEvent(runtimeEvent);
            _emitToFlutter.Invoke(json);
        }

        void OnDestroy()
        {
            if (Instance == this) Instance = null;
        }
    }
}
