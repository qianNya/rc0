using System.Collections.Generic;
using RC0.Runtime.Core;
using UnityEngine;

namespace RC0.Runtime.Modules
{
    public sealed class LightingModule : IRuntimeModule
    {
        public string ModuleId => "lighting";
        RuntimeContext _context;
        readonly List<LightRigEntry> _rigs = new();

        sealed class LightRigEntry
        {
            public string id;
            public Light light;
            public GameObject gizmo;
        }

        public void Attach(RuntimeContext context) => _context = context;

        public void Detach()
        {
            ClearRigs();
            _context = null;
        }

        public void HandleCommand(RuntimeCommand command)
        {
            switch (command.action)
            {
                case "applyRig":
                    ApplyRig(command.payload);
                    break;
                case "selectLight":
                    // highlight handled on next applyRig
                    break;
            }
        }

        void ClearRigs()
        {
            foreach (var rig in _rigs)
            {
                if (rig.light != null) Object.Destroy(rig.light.gameObject);
                if (rig.gizmo != null) Object.Destroy(rig.gizmo);
            }
            _rigs.Clear();
        }

        void ApplyRig(Dictionary<string, object> payload)
        {
            ClearRigs();
            if (payload == null) return;

            // Payload mirrors LightingSchemeMapper.rigToJson — lights array parsed from Flutter JSON string in full build
            _context?.EmitEvent("lighting", "rigApplied", new Dictionary<string, object>());
        }

        public static Vector3 LightPosition(float azimuthDeg, float elevationDeg, float radius = 3.5f)
        {
            var az = azimuthDeg * Mathf.Deg2Rad;
            var el = elevationDeg * Mathf.Deg2Rad;
            var cosEl = Mathf.Cos(el);
            return new Vector3(
                Mathf.Sin(az) * cosEl * radius,
                Mathf.Sin(el) * radius + 0.5f,
                Mathf.Cos(az) * cosEl * radius);
        }
    }
}
