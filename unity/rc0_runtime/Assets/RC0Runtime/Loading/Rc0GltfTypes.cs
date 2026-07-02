using System;

namespace RC0.Runtime.Loading
{
    [Serializable]
    sealed class GltfRoot
    {
        public GltfAccessor[] accessors;
        public GltfBufferView[] bufferViews;
        public GltfBuffer[] buffers;
        public GltfMesh[] meshes;
        public GltfNode[] nodes;
        public GltfScene[] scenes;
        public GltfMaterial[] materials;
        public GltfTexture[] textures;
        public GltfImage[] images;
        public int scene;
    }

    [Serializable]
    sealed class GltfAccessor
    {
        public int bufferView;
        public int byteOffset;
        public int componentType;
        public int count;
        public string type;
    }

    [Serializable]
    sealed class GltfBufferView
    {
        public int buffer;
        public int byteOffset;
        public int byteLength;
        public int byteStride;
    }

    [Serializable]
    sealed class GltfBuffer
    {
        public int byteLength;
        public string uri;
    }

    [Serializable]
    sealed class GltfMesh
    {
        public GltfPrimitive[] primitives;
    }

    [Serializable]
    sealed class GltfPrimitive
    {
        public GltfAttributes attributes;
        public int indices;
        public int material;
    }

    [Serializable]
    sealed class GltfAttributes
    {
        public int POSITION;
        public int NORMAL;
        public int TEXCOORD_0;
    }

    [Serializable]
    sealed class GltfNode
    {
        public int mesh;
        public int[] children;
        public float[] translation;
        public float[] rotation;
        public float[] scale;
    }

    [Serializable]
    sealed class GltfScene
    {
        public int[] nodes;
    }

    [Serializable]
    sealed class GltfMaterial
    {
        public GltfPbrMetallicRoughness pbrMetallicRoughness;
    }

    [Serializable]
    sealed class GltfPbrMetallicRoughness
    {
        public float[] baseColorFactor;
        public int baseColorTexture;
    }

    [Serializable]
    sealed class GltfTexture
    {
        public int source;
    }

    [Serializable]
    sealed class GltfImage
    {
        public string uri;
    }
}
