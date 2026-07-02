using System;
using System.Collections.Generic;
using RC0.Runtime.Modules;
using UnityEngine;

namespace RC0.Runtime.Core
{
    /// <summary>Bootstraps all runtime modules and routes commands.</summary>
    public sealed class RuntimeBootstrap : MonoBehaviour
    {
        public static RuntimeBootstrap Instance { get; private set; }

        readonly ModuleRegistry _registry = new();
        readonly Dictionary<string, RuntimeContext> _sessions = new();
        FlutterBridge _bridge;

        void Awake()
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);

            _registry.Register(new SceneModule());
            _registry.Register(new RenderModule());
            _registry.Register(new CameraModule());
            _registry.Register(new CharacterModule());
            _registry.Register(new LightingModule());
            _registry.Register(new PoseModule());
            _registry.Register(new AnimationModule());
            _registry.Register(new MaterialModule());
            _registry.Register(new AssetStreamingModule());
            _registry.Register(new ExportModule());
            _registry.Register(new PhysicsModule());
            _registry.Register(new AiInteractionModule());

            _bridge = gameObject.AddComponent<FlutterBridge>();
            _bridge.Initialize(this, EmitJsonToFlutter);
        }

        void OnDestroy()
        {
            _registry.DetachAll();
            if (Instance == this) Instance = null;
        }

        public void EnsureSession(string sessionId)
        {
            if (_sessions.ContainsKey(sessionId)) return;
            var context = new RuntimeContext(this, sessionId);
            _sessions[sessionId] = context;
            _registry.AttachAll(context);
        }

        public void HandleFlutterJson(string json)
        {
            var command = RuntimeJson.ParseCommand(json);
            if (command == null) return;
            EnsureSession(command.sessionId ?? "default");
            _registry.Dispatch(command);
        }

        public void EmitEvent(string sessionId, string moduleId, string eventName,
            Dictionary<string, object> payload)
        {
            var runtimeEvent = new RuntimeEvent
            {
                v = 1,
                sessionId = sessionId,
                module = moduleId,
                eventName = eventName,
                payload = payload ?? new Dictionary<string, object>(),
            };
            _bridge?.Emit(runtimeEvent);
        }

        void EmitJsonToFlutter(string json)
        {
#if UNITY_IOS && !UNITY_EDITOR
            NativeBridge_SendToFlutter(json);
#elif UNITY_ANDROID && !UNITY_EDITOR
            using (var unityPlayer = new AndroidJavaClass("com.rc0.unity.Rc0UnityBridge"))
            {
                unityPlayer.CallStatic("sendToFlutter", json);
            }
#elif UNITY_WEBGL && !UNITY_EDITOR
            WebBridge_SendToFlutter(json);
#elif UNITY_STANDALONE_OSX && !UNITY_EDITOR
            RC0.Runtime.Plugins.MacOsIpcBridge.SendToFlutter(json);
#else
            Debug.Log($"[RC0Runtime] → Flutter: {json}");
#endif
        }

#if UNITY_IOS && !UNITY_EDITOR
        [System.Runtime.InteropServices.DllImport("__Internal")]
        static extern void NativeBridge_SendToFlutter(string json);
#endif

#if UNITY_WEBGL && !UNITY_EDITOR
        [System.Runtime.InteropServices.DllImport("__Internal")]
        static extern void WebBridge_SendToFlutter(string json);
#endif
    }
}
