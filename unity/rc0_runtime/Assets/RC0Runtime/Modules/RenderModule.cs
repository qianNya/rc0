using RC0.Runtime.Core;
using UnityEngine;

namespace RC0.Runtime.Modules
{
    public sealed class RenderModule : IRuntimeModule
    {
        public string ModuleId => "render";
        RuntimeContext _context;

        public void Attach(RuntimeContext context) => _context = context;

        public void Detach() => _context = null;

        public void HandleCommand(RuntimeCommand command)
        {
            switch (command.action)
            {
                case "setMsaa":
                    QualitySettings.antiAliasing = 4;
                    break;
            }
        }
    }
}
