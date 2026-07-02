using UnityEngine;

namespace RC0.Runtime.Loading
{
    static class ModelBoundsUtility
    {
        public static Bounds CalculateBounds(GameObject root)
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

        public static void NormalizeToGround(GameObject root, float targetHeight)
        {
            var bounds = CalculateBounds(root);
            if (bounds.size == Vector3.zero) return;

            var maxAxis = Mathf.Max(bounds.size.x, bounds.size.y, bounds.size.z);
            if (maxAxis > 0.001f)
            {
                var scale = targetHeight / maxAxis;
                root.transform.localScale *= scale;
                bounds = CalculateBounds(root);
            }

            var offset = new Vector3(
                -bounds.center.x,
                -bounds.min.y,
                -bounds.center.z);
            root.transform.position += offset;
        }
    }
}
