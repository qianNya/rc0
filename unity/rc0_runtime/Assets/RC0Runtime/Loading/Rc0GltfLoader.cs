using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using RC0.Runtime.Modules;
using UnityEngine;
using UnityEngine.Networking;

namespace RC0.Runtime.Loading
{
    /// <summary>Runtime glTF / GLB loader (no external package).</summary>
    public static class Rc0GltfLoader
    {
        const int ComponentTypeFloat = 5126;
        const int ComponentTypeUShort = 5123;
        const int ComponentTypeUInt = 5125;

        public static IEnumerator LoadAsync(string sourcePath, Action<GameObject, string> onComplete)
        {
            if (string.IsNullOrEmpty(sourcePath))
            {
                onComplete?.Invoke(null, "empty path");
                yield break;
            }

            var normalized = NormalizePath(sourcePath);
            var extension = Path.GetExtension(normalized)?.TrimStart('.').ToLowerInvariant();

            byte[] jsonBytes = null;
            byte[] binBytes = null;
            string baseDir = null;

            if (extension == "glb")
            {
                byte[] glbBytes = null;
                yield return ReadAllBytesAsync(normalized, bytes => glbBytes = bytes);
                if (glbBytes == null || glbBytes.Length < 20)
                {
                    onComplete?.Invoke(null, "invalid glb");
                    yield break;
                }

                if (!TryParseGlb(glbBytes, out jsonBytes, out binBytes))
                {
                    onComplete?.Invoke(null, "glb parse failed");
                    yield break;
                }

                baseDir = Path.GetDirectoryName(normalized);
            }
            else
            {
                yield return ReadAllBytesAsync(normalized, bytes => jsonBytes = bytes);
                if (jsonBytes == null || jsonBytes.Length == 0)
                {
                    onComplete?.Invoke(null, "gltf read failed");
                    yield break;
                }

                baseDir = Path.GetDirectoryName(normalized);
                var root = ParseRoot(jsonBytes);
                if (root?.buffers != null && root.buffers.Length > 0 && !string.IsNullOrEmpty(root.buffers[0].uri))
                {
                    var binPath = ResolveUri(baseDir, root.buffers[0].uri);
                    yield return ReadAllBytesAsync(binPath, bytes => binBytes = bytes);
                }
            }

            GameObject instance = null;
            string error = null;
            try
            {
                instance = BuildScene(ParseRoot(jsonBytes), binBytes, baseDir);
                if (instance == null) error = "no mesh data";
            }
            catch (Exception ex)
            {
                error = ex.Message;
            }

            onComplete?.Invoke(instance, error);
        }

        static GltfRoot ParseRoot(byte[] jsonBytes)
        {
            if (jsonBytes == null || jsonBytes.Length == 0) return null;
            var json = Encoding.UTF8.GetString(jsonBytes);
            if (string.IsNullOrWhiteSpace(json)) return null;
            return JsonUtility.FromJson<GltfRoot>(json);
        }

        static GameObject BuildScene(GltfRoot root, byte[] binBytes, string baseDir)
        {
            if (root?.meshes == null || root.meshes.Length == 0) return null;

            var materials = BuildMaterials(root, baseDir);
            var meshObjects = new List<GameObject>();

            for (var meshIndex = 0; meshIndex < root.meshes.Length; meshIndex++)
            {
                var meshDef = root.meshes[meshIndex];
                if (meshDef?.primitives == null) continue;

                for (var primitiveIndex = 0; primitiveIndex < meshDef.primitives.Length; primitiveIndex++)
                {
                    var primitive = meshDef.primitives[primitiveIndex];
                    var mesh = BuildMesh(root, binBytes, primitive);
                    if (mesh == null) continue;

                    var go = new GameObject($"Mesh_{meshIndex}_{primitiveIndex}");
                    var filter = go.AddComponent<MeshFilter>();
                    filter.sharedMesh = mesh;
                    var renderer = go.AddComponent<MeshRenderer>();
                    var materialIndex = primitive.material;
                    renderer.sharedMaterial = materialIndex >= 0 && materialIndex < materials.Count
                        ? materials[materialIndex]
                        : MaterialFactory.CreateFallback(Color.white);
                    meshObjects.Add(go);
                }
            }

            if (meshObjects.Count == 0) return null;

            var rootGo = new GameObject("RC0_GltfModel");
            foreach (var meshObject in meshObjects)
            {
                meshObject.transform.SetParent(rootGo.transform, false);
            }

            ApplyNodeHierarchy(root, rootGo);
            ModelBoundsUtility.NormalizeToGround(rootGo, targetHeight: 1.8f);
            return rootGo;
        }

        static void ApplyNodeHierarchy(GltfRoot root, GameObject rootGo)
        {
            if (root.nodes == null || root.scenes == null || root.scenes.Length == 0) return;

            var sceneIndex = Mathf.Clamp(root.scene, 0, root.scenes.Length - 1);
            var scene = root.scenes[sceneIndex];
            if (scene?.nodes == null) return;

            var meshIndex = 0;
            foreach (var nodeIndex in scene.nodes)
            {
                ApplyNode(root, rootGo, nodeIndex, ref meshIndex);
            }
        }

        static void ApplyNode(GltfRoot root, GameObject rootGo, int nodeIndex, ref int meshIndex)
        {
            if (nodeIndex < 0 || nodeIndex >= root.nodes.Length) return;
            var node = root.nodes[nodeIndex];
            if (node == null) return;

            if (node.mesh >= 0 && meshIndex < rootGo.transform.childCount)
            {
                var child = rootGo.transform.GetChild(meshIndex);
                ApplyTransform(child, node);
                meshIndex++;
            }

            if (node.children == null) return;
            foreach (var childIndex in node.children)
            {
                ApplyNode(root, rootGo, childIndex, ref meshIndex);
            }
        }

        static void ApplyTransform(Transform transform, GltfNode node)
        {
            if (node.translation != null && node.translation.Length == 3)
            {
                transform.localPosition = new Vector3(node.translation[0], node.translation[1], node.translation[2]);
            }

            if (node.rotation != null && node.rotation.Length == 4)
            {
                transform.localRotation = new Quaternion(
                    node.rotation[0], node.rotation[1], node.rotation[2], node.rotation[3]);
            }

            if (node.scale != null && node.scale.Length == 3)
            {
                transform.localScale = new Vector3(node.scale[0], node.scale[1], node.scale[2]);
            }
        }

        static List<Material> BuildMaterials(GltfRoot root, string baseDir)
        {
            var materials = new List<Material>();
            if (root.materials == null) return materials;

            for (var i = 0; i < root.materials.Length; i++)
            {
                var def = root.materials[i];
                var color = Color.white;
                if (def?.pbrMetallicRoughness?.baseColorFactor != null &&
                    def.pbrMetallicRoughness.baseColorFactor.Length >= 3)
                {
                    var factors = def.pbrMetallicRoughness.baseColorFactor;
                    var alpha = factors.Length > 3 ? factors[3] : 1f;
                    color = new Color(factors[0], factors[1], factors[2], alpha);
                }

                var material = MaterialFactory.CreateFallback(color);
                TryApplyBaseColorTexture(root, baseDir, def, material);
                materials.Add(material);
            }

            return materials;
        }

        static void TryApplyBaseColorTexture(GltfRoot root, string baseDir, GltfMaterial def, Material material)
        {
            if (def?.pbrMetallicRoughness == null || root.textures == null || root.images == null) return;

            var textureIndex = def.pbrMetallicRoughness.baseColorTexture;
            if (textureIndex < 0 || textureIndex >= root.textures.Length) return;

            var textureDef = root.textures[textureIndex];
            if (textureDef.source < 0 || textureDef.source >= root.images.Length) return;

            var image = root.images[textureDef.source];
            if (string.IsNullOrEmpty(image.uri)) return;

            var imagePath = ResolveUri(baseDir, image.uri);
            if (!File.Exists(imagePath)) return;

            var bytes = File.ReadAllBytes(imagePath);
            var texture = new Texture2D(2, 2, TextureFormat.RGBA32, false);
            if (!texture.LoadImage(bytes)) return;

            material.mainTexture = texture;
        }

        static Mesh BuildMesh(GltfRoot root, byte[] binBytes, GltfPrimitive primitive)
        {
            if (primitive?.attributes == null || binBytes == null) return null;

            var positions = ReadVec3(root, binBytes, primitive.attributes.POSITION);
            if (positions == null || positions.Length == 0) return null;

            var mesh = new Mesh { name = "Rc0GltfMesh" };
            mesh.SetVertices(new List<Vector3>(positions));

            var normals = ReadVec3(root, binBytes, primitive.attributes.NORMAL);
            if (normals != null && normals.Length == positions.Length)
            {
                mesh.SetNormals(new List<Vector3>(normals));
            }
            else
            {
                mesh.RecalculateNormals();
            }

            var uvs = ReadVec2(root, binBytes, primitive.attributes.TEXCOORD_0);
            if (uvs != null && uvs.Length == positions.Length)
            {
                mesh.SetUVs(0, new List<Vector2>(uvs));
            }

            if (primitive.indices >= 0)
            {
                var indices = ReadIndices(root, binBytes, primitive.indices);
                if (indices != null && indices.Length > 0)
                {
                    mesh.SetIndices(indices, MeshTopology.Triangles, 0);
                }
            }
            else
            {
                var sequential = new int[positions.Length];
                for (var i = 0; i < sequential.Length; i++) sequential[i] = i;
                mesh.SetIndices(sequential, MeshTopology.Triangles, 0);
            }

            mesh.RecalculateBounds();
            return mesh;
        }

        static Vector3[] ReadVec3(GltfRoot root, byte[] binBytes, int accessorIndex)
        {
            return ReadTyped(root, binBytes, accessorIndex, 3, v => new Vector3(v[0], v[1], v[2]));
        }

        static Vector2[] ReadVec2(GltfRoot root, byte[] binBytes, int accessorIndex)
        {
            if (accessorIndex < 0) return null;
            return ReadTyped(root, binBytes, accessorIndex, 2, v => new Vector2(v[0], v[1]));
        }

        static int[] ReadIndices(GltfRoot root, byte[] binBytes, int accessorIndex)
        {
            if (accessorIndex < 0 || root.accessors == null || accessorIndex >= root.accessors.Length) return null;
            var accessor = root.accessors[accessorIndex];
            if (accessor == null || accessor.type != "SCALAR") return null;

            var data = ReadRaw(root, binBytes, accessor);
            if (data == null) return null;

            var result = new int[accessor.count];
            var offset = 0;
            for (var i = 0; i < accessor.count; i++)
            {
                switch (accessor.componentType)
                {
                    case ComponentTypeUShort:
                        result[i] = BitConverter.ToUInt16(data, offset);
                        offset += 2;
                        break;
                    case ComponentTypeUInt:
                        result[i] = (int)BitConverter.ToUInt32(data, offset);
                        offset += 4;
                        break;
                    default:
                        return null;
                }
            }

            return result;
        }

        static T[] ReadTyped<T>(GltfRoot root, byte[] binBytes, int accessorIndex, int components,
            Func<float[], T> map)
        {
            if (accessorIndex < 0 || root.accessors == null || accessorIndex >= root.accessors.Length) return null;
            var accessor = root.accessors[accessorIndex];
            if (accessor == null || accessor.componentType != ComponentTypeFloat) return null;

            var data = ReadRaw(root, binBytes, accessor);
            if (data == null) return null;

            var result = new T[accessor.count];
            var stride = components * 4;
            for (var i = 0; i < accessor.count; i++)
            {
                var values = new float[components];
                for (var c = 0; c < components; c++)
                {
                    values[c] = BitConverter.ToSingle(data, i * stride + c * 4);
                }

                result[i] = map(values);
            }

            return result;
        }

        static byte[] ReadRaw(GltfRoot root, byte[] binBytes, GltfAccessor accessor)
        {
            if (root.bufferViews == null || accessor.bufferView < 0 || accessor.bufferView >= root.bufferViews.Length)
            {
                return null;
            }

            var view = root.bufferViews[accessor.bufferView];
            var start = view.byteOffset + accessor.byteOffset;
            var length = GetComponentByteSize(accessor.componentType) * GetTypeComponents(accessor.type) * accessor.count;
            if (start + length > binBytes.Length) return null;

            var slice = new byte[length];
            Buffer.BlockCopy(binBytes, start, slice, 0, length);
            return slice;
        }

        static int GetComponentByteSize(int componentType)
        {
            return componentType switch
            {
                ComponentTypeFloat => 4,
                ComponentTypeUShort => 2,
                ComponentTypeUInt => 4,
                _ => 4,
            };
        }

        static int GetTypeComponents(string type)
        {
            return type switch
            {
                "SCALAR" => 1,
                "VEC2" => 2,
                "VEC3" => 3,
                "VEC4" => 4,
                _ => 1,
            };
        }

        static bool TryParseGlb(byte[] glbBytes, out byte[] jsonBytes, out byte[] binBytes)
        {
            jsonBytes = null;
            binBytes = null;
            if (glbBytes.Length < 12) return false;

            var magic = BitConverter.ToUInt32(glbBytes, 0);
            if (magic != 0x46546C67) return false;

            var offset = 12;
            while (offset + 8 <= glbBytes.Length)
            {
                var chunkLength = BitConverter.ToInt32(glbBytes, offset);
                var chunkType = BitConverter.ToUInt32(glbBytes, offset + 4);
                offset += 8;
                if (offset + chunkLength > glbBytes.Length) break;

                var chunk = new byte[chunkLength];
                Buffer.BlockCopy(glbBytes, offset, chunk, 0, chunkLength);
                offset += chunkLength;

                if (chunkType == 0x4E4F534A) jsonBytes = chunk;
                else if (chunkType == 0x004E4942) binBytes = chunk;
            }

            return jsonBytes != null && binBytes != null;
        }

        static IEnumerator ReadAllBytesAsync(string path, Action<byte[]> onComplete)
        {
            if (string.IsNullOrEmpty(path))
            {
                onComplete?.Invoke(null);
                yield break;
            }

            var normalized = NormalizePath(path);

#if UNITY_IOS && !UNITY_EDITOR
            if (IsUnderStreamingAssets(normalized))
            {
                yield return ReadStreamingAssetBytesAsync(normalized, onComplete);
                yield break;
            }
#endif

            try
            {
                onComplete?.Invoke(File.Exists(normalized) ? File.ReadAllBytes(normalized) : null);
            }
            catch (Exception)
            {
                onComplete?.Invoke(null);
            }
        }

        static bool IsUnderStreamingAssets(string path)
        {
            var root = Application.streamingAssetsPath;
            return !string.IsNullOrEmpty(root) &&
                   path.StartsWith(root, StringComparison.Ordinal);
        }

#if UNITY_IOS && !UNITY_EDITOR
        static IEnumerator ReadStreamingAssetBytesAsync(string path, Action<byte[]> onComplete)
        {
            byte[] data = null;
            var root = Application.streamingAssetsPath;
            var candidates = new List<string> { path };

            if (!path.Contains("://", StringComparison.Ordinal))
            {
                candidates.Add("file://" + path);
            }

            if (path.StartsWith(root, StringComparison.Ordinal))
            {
                var relative = path.Substring(root.Length).TrimStart('/', '\\');
                if (!string.IsNullOrEmpty(relative))
                {
                    candidates.Add(Path.Combine(root, relative));
                }
            }

            foreach (var url in candidates)
            {
                using var request = UnityWebRequest.Get(url);
                yield return request.SendWebRequest();
                if (request.result != UnityWebRequest.Result.Success) continue;

                var bytes = request.downloadHandler?.data;
                if (bytes != null && bytes.Length > 0)
                {
                    data = bytes;
                    break;
                }
            }

            onComplete?.Invoke(data);
        }
#endif

        static string NormalizePath(string path)
        {
            if (path.StartsWith("file://", StringComparison.OrdinalIgnoreCase))
            {
                path = path.Substring("file://".Length);
            }

            return path;
        }

        static string ResolveUri(string baseDir, string uri)
        {
            if (uri.StartsWith("data:", StringComparison.OrdinalIgnoreCase)) return null;
            if (Path.IsPathRooted(uri)) return uri;
            return Path.Combine(baseDir ?? string.Empty, uri);
        }
    }
}
