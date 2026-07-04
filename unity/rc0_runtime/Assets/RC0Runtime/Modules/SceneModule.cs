using RC0.Runtime.Core;
using UnityEngine;

namespace RC0.Runtime.Modules
{
    public sealed class SceneModule : IRuntimeModule
    {
        public string ModuleId => "scene";
        RuntimeContext _context;
        GameObject _environmentRoot;

        public void Attach(RuntimeContext context)
        {
            _context = context;
            EnsureEnvironment();
        }

        public void Detach()
        {
            if (_environmentRoot != null)
            {
                Object.Destroy(_environmentRoot);
                _environmentRoot = null;
            }
            _context = null;
        }

        public void HandleCommand(RuntimeCommand command)
        {
            switch (command.action)
            {
                case "setMode":
                    EnsureEnvironment();
                    break;
                case "dispose":
                    Detach();
                    break;
            }
        }

        void EnsureEnvironment()
        {
            SuppressTemplateScene();
            if (_environmentRoot != null) return;
            _environmentRoot = new GameObject("RC0_Environment");
            var floor = GameObject.CreatePrimitive(PrimitiveType.Plane);
            floor.name = "Floor";
            floor.transform.SetParent(_environmentRoot.transform);
            floor.transform.localScale = new Vector3(0.8f, 1f, 0.8f);
            var renderer = floor.GetComponent<Renderer>();
            if (renderer != null)
            {
                renderer.material.color = new Color(0.16f, 0.15f, 0.22f);
            }
        }

        static void SuppressTemplateScene()
        {
            var cube = GameObject.Find("Cube");
            if (cube != null) cube.SetActive(false);

            var templateCamera = GameObject.Find("Main Camera");
            if (templateCamera != null)
            {
                var camera = templateCamera.GetComponent<Camera>();
                if (camera != null) camera.enabled = false;
            }
        }
    }
}
