using System.Collections.Generic;
using RC0.Runtime.Core;
using UnityEngine;

namespace RC0.Runtime.Modules
{
    public sealed class PoseModule : IRuntimeModule
    {
        public string ModuleId => "pose";
        RuntimeContext _context;
        string _currentPose = "standing";

        public void Attach(RuntimeContext context) => _context = context;

        public void Detach() => _context = null;

        public void HandleCommand(RuntimeCommand command)
        {
            if (command.action != "apply") return;

            _currentPose = RuntimeJson.ReadString(command.payload, "mode") ?? "standing";
            ApplyPose(_currentPose);
            _context?.EmitEvent("pose", "applied", new Dictionary<string, object>
            {
                { "mode", _currentPose },
            });
        }

        static void ApplyPose(string pose)
        {
            var controller = CameraInteractionController.Active;
            if (controller == null) return;

            switch (pose)
            {
                case "sitting":
                    controller.SetModelScale(0.95f);
                    controller.SetModelYaw(0f);
                    break;
                case "walking":
                    controller.SetModelYaw(20f);
                    break;
                case "running":
                    controller.SetModelYaw(35f);
                    controller.SetModelScale(1.05f);
                    break;
                case "jumping":
                    controller.SetModelScale(1.08f);
                    controller.SetModelYaw(0f);
                    break;
                case "crouching":
                    controller.SetModelScale(0.82f);
                    break;
                case "kneeling":
                    controller.SetModelScale(0.88f);
                    controller.SetModelYaw(15f);
                    break;
                case "lying":
                    controller.SetModelScale(0.9f);
                    controller.SetModelYaw(90f);
                    break;
                case "armsUp":
                    controller.SetModelScale(1.02f);
                    controller.SetModelYaw(0f);
                    break;
                case "waving":
                    controller.SetModelYaw(-25f);
                    break;
                default:
                    controller.SetModelScale(1f);
                    controller.SetModelYaw(0f);
                    break;
            }
        }
    }
}
