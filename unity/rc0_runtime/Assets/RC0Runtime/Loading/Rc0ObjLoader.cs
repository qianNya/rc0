using System.Collections.Generic;
using System.Globalization;
using System.IO;
using UnityEngine;

namespace RC0.Runtime.Loading
{
    /// <summary>Minimal Wavefront OBJ loader for runtime imports.</summary>
    public static class Rc0ObjLoader
    {
        public static GameObject Load(string path)
        {
            if (string.IsNullOrEmpty(path) || !File.Exists(path)) return null;

            var vertices = new List<Vector3>();
            var uvs = new List<Vector2>();
            var meshVertices = new List<Vector3>();
            var meshUvs = new List<Vector2>();
            var indices = new List<int>();

            foreach (var rawLine in File.ReadLines(path))
            {
                var line = rawLine.Trim();
                if (line.Length == 0 || line.StartsWith("#")) continue;

                var parts = line.Split((char[])null, System.StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length == 0) continue;

                switch (parts[0])
                {
                    case "v" when parts.Length >= 4:
                        vertices.Add(new Vector3(
                            ParseFloat(parts[1]),
                            ParseFloat(parts[2]),
                            ParseFloat(parts[3])));
                        break;
                    case "vt" when parts.Length >= 3:
                        uvs.Add(new Vector2(ParseFloat(parts[1]), ParseFloat(parts[2])));
                        break;
                    case "f" when parts.Length >= 4:
                        AppendFace(parts, vertices, uvs, meshVertices, meshUvs, indices);
                        break;
                }
            }

            if (meshVertices.Count == 0) return null;

            var mesh = new Mesh { name = "Rc0ObjMesh" };
            mesh.SetVertices(meshVertices);
            if (meshUvs.Count == meshVertices.Count) mesh.SetUVs(0, meshUvs);
            mesh.SetIndices(indices, MeshTopology.Triangles, 0);
            mesh.RecalculateNormals();
            mesh.RecalculateBounds();

            var root = new GameObject("RC0_ObjModel");
            var filter = root.AddComponent<MeshFilter>();
            filter.sharedMesh = mesh;
            var renderer = root.AddComponent<MeshRenderer>();
            renderer.sharedMaterial = MaterialFactory.CreateFallback(Color.white);

            ModelBoundsUtility.NormalizeToGround(root, targetHeight: 1.8f);
            return root;
        }

        static void AppendFace(
            string[] parts,
            List<Vector3> vertices,
            List<Vector2> uvs,
            List<Vector3> meshVertices,
            List<Vector2> meshUvs,
            List<int> indices)
        {
            var faceIndices = new List<int>();
            for (var i = 1; i < parts.Length; i++)
            {
                var tokens = parts[i].Split('/');
                var vertexIndex = ParseIndex(tokens[0], vertices.Count);
                var uvIndex = tokens.Length > 1 && tokens[1].Length > 0
                    ? ParseIndex(tokens[1], uvs.Count)
                    : -1;

                meshVertices.Add(vertices[vertexIndex]);
                if (uvIndex >= 0 && uvIndex < uvs.Count) meshUvs.Add(uvs[uvIndex]);
                faceIndices.Add(meshVertices.Count - 1);
            }

            for (var i = 1; i < faceIndices.Count - 1; i++)
            {
                indices.Add(faceIndices[0]);
                indices.Add(faceIndices[i]);
                indices.Add(faceIndices[i + 1]);
            }
        }

        static int ParseIndex(string token, int count)
        {
            var index = ParseInt(token);
            if (index < 0) index = count + index;
            return Mathf.Clamp(index, 0, count - 1);
        }

        static float ParseFloat(string value) =>
            float.Parse(value, CultureInfo.InvariantCulture);

        static int ParseInt(string value) =>
            int.Parse(value, CultureInfo.InvariantCulture);
    }
}
