using System.Collections.Generic;

namespace RC0.Runtime.Core
{
    public sealed class ModuleRegistry
    {
        readonly Dictionary<string, IRuntimeModule> _modules = new();

        public void Register(IRuntimeModule module)
        {
            _modules[module.ModuleId] = module;
        }

        public bool TryGet(string moduleId, out IRuntimeModule module)
        {
            return _modules.TryGetValue(moduleId, out module);
        }

        public void AttachAll(RuntimeContext context)
        {
            foreach (var module in _modules.Values)
            {
                module.Attach(context);
            }
        }

        public void DetachAll()
        {
            foreach (var module in _modules.Values)
            {
                module.Detach();
            }
        }

        public void Dispatch(RuntimeCommand command)
        {
            if (command == null || string.IsNullOrEmpty(command.module)) return;
            if (_modules.TryGetValue(command.module, out var module))
            {
                module.HandleCommand(command);
            }
        }
    }
}
