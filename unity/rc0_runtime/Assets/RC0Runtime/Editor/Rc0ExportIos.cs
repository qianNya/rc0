using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace RC0.Runtime.Editor
{
    public static class Rc0ExportIos
    {
        const string ExportPath = "ios";

        public static void Export()
        {
            var scenes = EditorBuildSettings.scenes;
            var enabled = new System.Collections.Generic.List<string>();
            foreach (var scene in scenes)
            {
                if (scene.enabled) enabled.Add(scene.path);
            }

            if (enabled.Count == 0)
            {
                enabled.Add("Assets/ios.scene");
            }

            Debug.Log($"[RC0] Exporting iOS → {ExportPath}, scenes: {string.Join(", ", enabled)}");

            var options = BuildOptions.None;
            var report = BuildPipeline.BuildPlayer(
                enabled.ToArray(),
                ExportPath,
                BuildTarget.iOS,
                options);

            if (report.summary.result != BuildResult.Succeeded)
            {
                Debug.LogError($"[RC0] iOS export failed: {report.summary.result}");
                EditorApplication.Exit(1);
                return;
            }

            Debug.Log("[RC0] iOS export succeeded");
            EditorApplication.Exit(0);
        }
    }
}
