using UnityEngine;

namespace RC0.Runtime.Modules
{
    /// <summary>Touch / mouse orbit, pan, and pinch zoom for the RC0 preview camera.</summary>
    public sealed class CameraInteractionController : MonoBehaviour
    {
        public static CameraInteractionController Active { get; private set; }

        [SerializeField] Transform focusTarget;
        [SerializeField] float distance = 5f;
        [SerializeField] float minDistance = 1.2f;
        [SerializeField] float maxDistance = 18f;
        [SerializeField] float yaw = 0f;
        [SerializeField] float pitch = 18f;
        [SerializeField] float orbitSpeed = 0.25f;
        [SerializeField] float panSpeed = 0.0035f;
        [SerializeField] float zoomSpeed = 0.01f;
        [SerializeField] float minPitch = -20f;
        [SerializeField] float maxPitch = 80f;

        Vector3 _focusPoint = new(0f, 1f, 0f);
        bool _planView;
        bool _autoRotate;
        bool _userInteracting;
        Vector2 _lastPointer;
        float _lastPinchDistance = -1f;
        float _modelScale = 1f;
        float _modelYawOffset;

        public bool UserInteracting => _userInteracting;

        void OnEnable() => Active = this;

        void OnDisable()
        {
            if (Active == this) Active = null;
        }

        void LateUpdate()
        {
            if (_planView) return;
            HandlePointerInput();
            ApplyCameraTransform();
        }

        public void Configure(bool planView, bool autoRotate)
        {
            _planView = planView;
            _autoRotate = autoRotate;
            if (_planView)
            {
                _userInteracting = false;
            }
        }

        public void ResetView(Vector3 focusPoint, float initialDistance)
        {
            _focusPoint = focusPoint;
            distance = Mathf.Clamp(initialDistance, minDistance, maxDistance);
            yaw = 0f;
            pitch = 18f;
            _modelScale = 1f;
            _modelYawOffset = 0f;
            ApplyModelTransform();
            ApplyCameraTransform();
        }

        public void SetFocusTarget(Transform target, bool snap = true)
        {
            focusTarget = target;
            if (target == null) return;

            var bounds = CalculateBounds(target.gameObject);
            _focusPoint = bounds.center;
            if (snap)
            {
                distance = Mathf.Clamp(Mathf.Max(bounds.extents.x, bounds.extents.y, bounds.extents.z) * 2.4f,
                    minDistance, maxDistance);
            }

            ApplyModelTransform();
            ApplyCameraTransform();
        }

        public void SetModelYaw(float degrees)
        {
            _modelYawOffset = degrees;
            ApplyModelTransform();
        }

        public void SetModelScale(float scale)
        {
            _modelScale = Mathf.Clamp(scale, 0.2f, 4f);
            ApplyModelTransform();
            if (focusTarget != null)
            {
                var bounds = CalculateBounds(focusTarget.gameObject);
                _focusPoint = bounds.center;
            }
        }

        void HandlePointerInput()
        {
            _userInteracting = false;

#if UNITY_EDITOR || UNITY_STANDALONE
            if (Input.GetMouseButton(0))
            {
                var delta = (Vector2)Input.mousePosition - _lastPointer;
                if (Input.GetMouseButtonDown(0)) delta = Vector2.zero;
                Orbit(delta);
                _lastPointer = Input.mousePosition;
                _userInteracting = true;
            }

            if (Input.GetMouseButton(1) || Input.GetMouseButton(2))
            {
                var delta = (Vector2)Input.mousePosition - _lastPointer;
                if (Input.GetMouseButtonDown(1) || Input.GetMouseButtonDown(2)) delta = Vector2.zero;
                Pan(delta);
                _lastPointer = Input.mousePosition;
                _userInteracting = true;
            }

            var scroll = Input.mouseScrollDelta.y;
            if (Mathf.Abs(scroll) > 0.001f)
            {
                Zoom(scroll * 12f);
                _userInteracting = true;
            }
#endif
            if (Input.touchCount == 1)
            {
                var touch = Input.GetTouch(0);
                if (touch.phase == TouchPhase.Moved)
                {
                    Orbit(touch.deltaPosition);
                    _userInteracting = true;
                }
            }
            else if (Input.touchCount == 2)
            {
                var t0 = Input.GetTouch(0);
                var t1 = Input.GetTouch(1);
                var currentDistance = Vector2.Distance(t0.position, t1.position);
                if (_lastPinchDistance > 0f)
                {
                    Zoom((currentDistance - _lastPinchDistance) * zoomSpeed * 60f);
                    _userInteracting = true;
                }

                if (t0.phase == TouchPhase.Moved || t1.phase == TouchPhase.Moved)
                {
                    var prev0 = t0.position - t0.deltaPosition;
                    var prev1 = t1.position - t1.deltaPosition;
                    var prevMid = (prev0 + prev1) * 0.5f;
                    var currentMid = (t0.position + t1.position) * 0.5f;
                    Pan(currentMid - prevMid);
                    _userInteracting = true;
                }

                _lastPinchDistance = currentDistance;
            }
            else
            {
                _lastPinchDistance = -1f;
            }

            if (_autoRotate && !_userInteracting)
            {
                yaw += Time.deltaTime * 24f;
            }
        }

        void Orbit(Vector2 delta)
        {
            yaw += delta.x * orbitSpeed;
            pitch = Mathf.Clamp(pitch - delta.y * orbitSpeed, minPitch, maxPitch);
        }

        void Pan(Vector2 delta)
        {
            var right = transform.right;
            var up = Vector3.up;
            _focusPoint -= (right * delta.x + up * delta.y) * panSpeed * distance;
            ApplyModelTransform();
        }

        void Zoom(float delta)
        {
            distance = Mathf.Clamp(distance - delta, minDistance, maxDistance);
        }

        void ApplyCameraTransform()
        {
            var rotation = Quaternion.Euler(pitch, yaw, 0f);
            var offset = rotation * new Vector3(0f, 0f, -distance);
            transform.position = _focusPoint + offset;
            transform.rotation = rotation;
        }

        void ApplyModelTransform()
        {
            if (focusTarget == null) return;
            focusTarget.localScale = Vector3.one * _modelScale;
            focusTarget.rotation = Quaternion.Euler(0f, _modelYawOffset, 0f);
        }

        static Bounds CalculateBounds(GameObject root)
        {
            var renderers = root.GetComponentsInChildren<Renderer>();
            if (renderers.Length == 0)
            {
                return new Bounds(root.transform.position, Vector3.one);
            }

            var bounds = renderers[0].bounds;
            for (var i = 1; i < renderers.Length; i++)
            {
                bounds.Encapsulate(renderers[i].bounds);
            }

            return bounds;
        }
    }
}
