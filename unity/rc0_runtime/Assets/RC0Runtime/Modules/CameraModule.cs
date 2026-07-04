using RC0.Runtime.Core;
using UnityEngine;

namespace RC0.Runtime.Modules
{
    public sealed class CameraModule : IRuntimeModule
    {
        public string ModuleId => "camera";
        RuntimeContext _context;
        Camera _camera;
        CameraInteractionController _interaction;
        CameraOrbitDriver _legacyOrbit;
        bool _planView;
        bool _autoRotate;

        public void Attach(RuntimeContext context)
        {
            _context = context;
            EnsureCamera();
        }

        public void Detach()
        {
            if (_camera != null)
            {
                Object.Destroy(_camera.gameObject);
                _camera = null;
                _interaction = null;
                _legacyOrbit = null;
            }

            _context = null;
        }

        public void HandleCommand(RuntimeCommand command)
        {
            EnsureCamera();
            switch (command.action)
            {
                case "reset":
                    ResetCamera();
                    break;
                case "setPlanView":
                    _planView = RuntimeJson.ReadBool(command.payload, "enabled");
                    ApplyCameraMode();
                    break;
                case "setAutoRotate":
                    _autoRotate = RuntimeJson.ReadBool(command.payload, "enabled");
                    ApplyAutoRotate();
                    break;
            }
        }

        void EnsureCamera()
        {
            if (_camera != null) return;
            var go = new GameObject("RC0_MainCamera");
            go.tag = "MainCamera";
            _camera = go.AddComponent<Camera>();
            _camera.clearFlags = CameraClearFlags.SolidColor;
            _camera.backgroundColor = new Color(0.07f, 0.06f, 0.09f);
            _camera.depth = 10;
            _interaction = go.AddComponent<CameraInteractionController>();
            ResetCamera();
        }

        void ResetCamera()
        {
            if (_camera == null) return;

            _camera.orthographic = _planView;
            if (_planView)
            {
                _camera.transform.position = new Vector3(0f, 10f, 0.01f);
                _camera.transform.rotation = Quaternion.Euler(90f, 0f, 0f);
                _camera.orthographicSize = 4f;
                _interaction?.Configure(true, false);
            }
            else
            {
                _interaction?.ResetView(new Vector3(0f, 1f, 0f), 5f);
                _interaction?.Configure(false, _autoRotate);
            }

            ApplyAutoRotate();
        }

        void ApplyCameraMode() => ResetCamera();

        void ApplyAutoRotate()
        {
            if (_camera == null) return;

            if (_legacyOrbit == null)
            {
                _legacyOrbit = _camera.gameObject.GetComponent<CameraOrbitDriver>();
            }

            if (_interaction != null)
            {
                _interaction.Configure(_planView, _autoRotate && !_interaction.UserInteracting);
            }

            if (_legacyOrbit != null)
            {
                _legacyOrbit.enabled = false;
            }
        }
    }
}
