using UnityEngine;

namespace RC0.Runtime.Modules
{
    sealed class CameraOrbitDriver : MonoBehaviour
    {
        float _angle;

        void Update()
        {
            _angle += Time.deltaTime * 24f;
            var target = new Vector3(0f, 1f, 0f);
            const float radius = 5f;
            var rad = _angle * Mathf.Deg2Rad;
            transform.position = target + new Vector3(
                Mathf.Sin(rad) * radius,
                1.4f,
                Mathf.Cos(rad) * radius);
            transform.LookAt(target);
        }
    }
}
