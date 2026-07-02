using UnityEngine;

namespace RC0.Runtime.Core
{
    /// <summary>
    /// Ensures RC0RuntimeBootstrap exists even when the exported iOS scene is ios.scene
    /// (Camera + Cube only). Flutter SendMessage targets this GameObject name.
    /// </summary>
    static class RuntimeBootstrapLoader
    {
        const string BootstrapObjectName = "RC0RuntimeBootstrap";

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void EnsureBootstrap()
        {
            if (RuntimeBootstrap.Instance != null) return;

            var existing = GameObject.Find(BootstrapObjectName);
            if (existing != null)
            {
                if (existing.GetComponent<RuntimeBootstrap>() == null)
                {
                    existing.AddComponent<RuntimeBootstrap>();
                }

                return;
            }

            var go = new GameObject(BootstrapObjectName);
            go.AddComponent<RuntimeBootstrap>();
        }
    }
}
