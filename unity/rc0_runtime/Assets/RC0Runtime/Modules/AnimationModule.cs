using System.Collections.Generic;
using RC0.Runtime.Core;

namespace RC0.Runtime.Modules
{
    public sealed class AnimationModule : IRuntimeModule
    {
        public string ModuleId => "animation";
        RuntimeContext _context;
        string _clipName;

        public void Attach(RuntimeContext context) => _context = context;
        public void Detach() => _context = null;

        public void HandleCommand(RuntimeCommand command)
        {
            switch (command.action)
            {
                case "play":
                    if (command.payload != null && command.payload.TryGetValue("name", out var name))
                    {
                        _clipName = name as string;
                    }
                    _context?.EmitEvent("animation", "playing", new Dictionary<string, object>
                    {
                        { "name", _clipName ?? "" },
                    });
                    break;
                case "stop":
                    _clipName = null;
                    break;
            }
        }
    }
}
