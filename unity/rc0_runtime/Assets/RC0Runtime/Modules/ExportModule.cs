using System.Collections.Generic;
using RC0.Runtime.Core;
using UnityEngine;

namespace RC0.Runtime.Modules
{
    public sealed class ExportModule : IRuntimeModule
    {
        public string ModuleId => "export";
        RuntimeContext _context;

        public void Attach(RuntimeContext context) => _context = context;
        public void Detach() => _context = null;

        public void HandleCommand(RuntimeCommand command)
        {
            if (command.action != "capturePng") return;
            var camera = Camera.main;
            if (camera == null) return;

            var rt = new RenderTexture(Screen.width, Screen.height, 24);
            camera.targetTexture = rt;
            camera.Render();
            RenderTexture.active = rt;
            var tex = new Texture2D(rt.width, rt.height, TextureFormat.RGB24, false);
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();
            camera.targetTexture = null;
            RenderTexture.active = null;
            Object.Destroy(rt);

            var bytes = tex.EncodeToPNG();
            Object.Destroy(tex);
            _context?.EmitEvent("export", "pngReady", new Dictionary<string, object>
            {
                { "byteLength", bytes.Length },
            });
        }
    }
}
