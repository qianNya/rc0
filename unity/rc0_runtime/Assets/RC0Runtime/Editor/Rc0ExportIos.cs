using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace RC0.Runtime.Editor
{
    public static class Rc0ExportIos
    {
        const string ExportPath = "ios";

        [MenuItem("RC0/Export iOS → ios/")]
        public static void ExportFromEditorMenu()
        {
            if (!EditorUtility.DisplayDialog(
                    "RC0 Export iOS",
                    $"Export to {ExportPath}/ ?\n\nAfter export, run from repo root:\n  ./scripts/build_tuanjie_ios.sh device",
                    "Export",
                    "Cancel"))
            {
                return;
            }

            ExportInternal(quitEditorOnFinish: false);
        }

        /// <summary>Called by scripts/export_tuanjie_ios.sh in batchmode.</summary>
        public static void Export()
        {
            ExportInternal(quitEditorOnFinish: true);
        }

        static void ExportInternal(bool quitEditorOnFinish)
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

            var report = BuildPipeline.BuildPlayer(
                enabled.ToArray(),
                ExportPath,
                BuildTarget.iOS,
                BuildOptions.None);

            if (report.summary.result != BuildResult.Succeeded)
            {
                Debug.LogError($"[RC0] iOS export failed: {report.summary.result}");
                if (quitEditorOnFinish) EditorApplication.Exit(1);
                return;
            }

            Debug.Log("[RC0] iOS export succeeded");
            if (quitEditorOnFinish)
            {
                EditorApplication.Exit(0);
            }
            else
            {
                EditorUtility.DisplayDialog(
                    "RC0 Export iOS",
                    "Export succeeded.\n\nNext in terminal:\n./scripts/build_tuanjie_ios.sh device",
                    "OK");
            }
        }
    }
}
