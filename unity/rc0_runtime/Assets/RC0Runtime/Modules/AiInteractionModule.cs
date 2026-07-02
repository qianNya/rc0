using System.Collections.Generic;
using RC0.Runtime.Core;

namespace RC0.Runtime.Modules
{
    /// <summary>V1 schema only — future natural-language lighting/camera control.</summary>
    public sealed class AiInteractionModule : IRuntimeModule
    {
        public string ModuleId => "aiInteraction";
        RuntimeContext _context;

        public void Attach(RuntimeContext context) => _context = context;
        public void Detach() => _context = null;

        public void HandleCommand(RuntimeCommand command)
        {
            if (command.action != "interpretNaturalLanguage") return;
            _context?.EmitEvent("aiInteraction", "notImplemented", new Dictionary<string, object>());
        }
    }
}
