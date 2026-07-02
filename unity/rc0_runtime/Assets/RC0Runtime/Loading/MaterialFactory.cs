using UnityEngine;

namespace RC0.Runtime.Loading
{
    static class MaterialFactory
    {
        public static Material CreateFallback(Color color)
        {
            var shader = Shader.Find("Universal Render Pipeline/Lit")
                         ?? Shader.Find("Standard")
                         ?? Shader.Find("Unlit/Color");
            var material = new Material(shader);
            if (material.HasProperty("_BaseColor"))
            {
                material.SetColor("_BaseColor", color);
            }
            else
            {
                material.color = color;
            }

            return material;
        }
    }
}
