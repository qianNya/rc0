using System.Collections;
using System.Collections.Generic;
using System.IO;
using RC0.Runtime.Core;
using RC0.Runtime.Loading;
using UnityEngine;

namespace RC0.Runtime.Modules
{
    public sealed class CharacterModule : IRuntimeModule
    {
        public string ModuleId => "character";
        RuntimeContext _context;
        GameObject _instance;
        MonoBehaviour _host;
        string _currentPath;

        public void Attach(RuntimeContext context)
        {
            _context = context;
            _host = RuntimeBootstrap.Instance;
        }

        public void Detach()
        {
            ClearInstance();
            _context = null;
            _host = null;
        }

        public void HandleCommand(RuntimeCommand command)
        {
            switch (command.action)
            {
                case "load":
                    if (_host != null)
                    {
                        _host.StartCoroutine(LoadFromPayload(command.payload));
                    }
                    break;
                case "clear":
                    ClearInstance();
                    break;
            }
        }

        void ClearInstance()
        {
            if (_instance != null)
            {
                Object.Destroy(_instance);
                _instance = null;
            }

            _currentPath = null;
            if (CameraInteractionController.Active != null)
            {
                CameraInteractionController.Active.SetFocusTarget(null);
            }
        }

        IEnumerator LoadFromPayload(Dictionary<string, object> payload)
        {
            ClearInstance();

            var path = RuntimeJson.ReadString(payload, "path");
            var bundledKey = RuntimeJson.ReadString(payload, "bundledKey");
            var extension = RuntimeJson.ReadString(payload, "extension")?.ToLowerInvariant();

            if (!string.IsNullOrEmpty(bundledKey))
            {
                path = ResolveBundledPath(bundledKey);
            }

            if (string.IsNullOrEmpty(path))
            {
                _instance = CreatePlaceholder("RC0_CharacterMissing");
                FinishLoad(_instance, new[] { "静态姿态" });
                yield break;
            }

            if (string.IsNullOrEmpty(extension))
            {
                extension = Path.GetExtension(path)?.TrimStart('.').ToLowerInvariant();
            }

            _currentPath = path;
            GameObject loaded = null;
            string error = null;

            if (extension == "obj")
            {
                loaded = Rc0ObjLoader.Load(path);
                if (loaded == null) error = "obj load failed";
            }
            else if (extension == "gltf" || extension == "glb")
            {
                yield return Rc0GltfLoader.LoadAsync(path, (go, loadError) =>
                {
                    loaded = go;
                    error = loadError;
                });
            }
            else
            {
                error = $"unsupported extension: {extension}";
            }

            if (loaded == null)
            {
                Debug.LogWarning($"[RC0Runtime] Character load failed ({path}): {error}");
                _instance = CreatePlaceholder("RC0_CharacterFallback");
                FinishLoad(_instance, new[] { "静态姿态" });
                yield break;
            }

            _instance = loaded;
            _instance.name = "RC0_Character";
            FinishLoad(_instance, CollectAnimationNames(_instance));
        }

        void FinishLoad(GameObject instance, string[] animationNames)
        {
            if (CameraInteractionController.Active != null)
            {
                CameraInteractionController.Active.SetFocusTarget(instance.transform);
            }

            _context?.EmitEvent("character", "ready", new Dictionary<string, object>
            {
                { "animationNames", animationNames },
                { "path", _currentPath ?? string.Empty },
            });
        }

        static string[] CollectAnimationNames(GameObject instance)
        {
            var names = new List<string> { "静态姿态" };
            var animator = instance.GetComponentInChildren<Animator>();
            if (animator != null && animator.runtimeAnimatorController != null)
            {
                foreach (var clip in animator.runtimeAnimatorController.animationClips)
                {
                    if (!string.IsNullOrEmpty(clip.name)) names.Add(clip.name);
                }
            }

            return names.ToArray();
        }

        static string ResolveBundledPath(string bundledKey)
        {
            var root = Application.streamingAssetsPath;
            return bundledKey switch
            {
                "aku_aku" => $"{root}/model/aku_aku/scene.gltf",
                "yt" => $"{root}/model/yt/羽蜕-浅憩之处.gltf",
                _ => null,
            };
        }

        static GameObject CreatePlaceholder(string name)
        {
            var root = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            root.name = name;
            root.transform.position = new Vector3(0f, 1f, 0f);
            root.transform.localScale = new Vector3(0.5f, 0.9f, 0.5f);
            var renderer = root.GetComponent<Renderer>();
            if (renderer != null)
            {
                renderer.material.color = new Color(0.61f, 0.36f, 1f, 0.85f);
            }

            return root;
        }
    }
}
