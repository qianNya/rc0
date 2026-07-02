#if UNITY_STANDALONE_OSX && !UNITY_EDITOR
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using RC0.Runtime.Core;
using UnityEngine;

namespace RC0.Runtime.Plugins
{
    /// <summary>
    /// Dev bridge: Flutter macOS host talks to a standalone Unity player over TCP.
    /// </summary>
    public static class MacOsIpcBridge
    {
        const int DefaultPort = 19721;
        static TcpListener _listener;
        static TcpClient _client;
        static StreamWriter _writer;
        static Thread _acceptThread;
        static Thread _readThread;
        static volatile bool _running;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void Bootstrap()
        {
            if (_running) return;
            _running = true;

            var port = DefaultPort;
            var env = Environment.GetEnvironmentVariable("RC0_UNITY_IPC_PORT");
            if (!string.IsNullOrEmpty(env) && int.TryParse(env, out var parsed))
            {
                port = parsed;
            }

            _listener = new TcpListener(IPAddress.Loopback, port);
            _listener.Start();
            Debug.Log($"[RC0Runtime] macOS IPC listening on 127.0.0.1:{port}");

            _acceptThread = new Thread(AcceptLoop) { IsBackground = true };
            _acceptThread.Start();
        }

        static void AcceptLoop()
        {
            while (_running)
            {
                try
                {
                    var client = _listener.AcceptTcpClient();
                    _client = client;
                    _writer = new StreamWriter(client.GetStream(), Encoding.UTF8) { AutoFlush = true };
                    _readThread = new Thread(ReadLoop) { IsBackground = true };
                    _readThread.Start(client);
                    Debug.Log("[RC0Runtime] macOS IPC client connected");
                }
                catch (Exception ex)
                {
                    if (_running) Debug.LogWarning($"[RC0Runtime] macOS IPC accept: {ex.Message}");
                }
            }
        }

        static void ReadLoop(object state)
        {
            var client = (TcpClient)state;
            using var reader = new StreamReader(client.GetStream(), Encoding.UTF8);
            while (_running && client.Connected)
            {
                string line;
                try
                {
                    line = reader.ReadLine();
                }
                catch
                {
                    break;
                }

                if (line == null) break;
                if (string.IsNullOrWhiteSpace(line)) continue;

                var bridge = FlutterBridge.Instance;
                if (bridge != null)
                {
                    MainThreadDispatcher.Enqueue(() => bridge.OnFlutterMessage(line));
                }
            }
        }

        public static void SendToFlutter(string json)
        {
            try
            {
                _writer?.WriteLine(json);
            }
            catch (Exception ex)
            {
                Debug.LogWarning($"[RC0Runtime] macOS IPC send failed: {ex.Message}");
            }
        }
    }

    static class MainThreadDispatcher
    {
        static readonly System.Collections.Generic.Queue<Action> Queue = new();
        static bool _hooked;

        public static void Enqueue(Action action)
        {
            lock (Queue)
            {
                Queue.Enqueue(action);
                if (!_hooked)
                {
                    _hooked = true;
                    var go = new GameObject("RC0_MainThreadDispatcher");
                    UnityEngine.Object.DontDestroyOnLoad(go);
                    go.AddComponent<DispatcherBehaviour>();
                }
            }
        }

        sealed class DispatcherBehaviour : MonoBehaviour
        {
            void Update()
            {
                while (true)
                {
                    Action action;
                    lock (Queue)
                    {
                        if (Queue.Count == 0) return;
                        action = Queue.Dequeue();
                    }
                    action?.Invoke();
                }
            }
        }
    }
}
#endif
