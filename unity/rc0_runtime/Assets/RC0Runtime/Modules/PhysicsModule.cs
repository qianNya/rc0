using RC0.Runtime.Core;

namespace RC0.Runtime.Modules
{
    /// <summary>V1 NoOp — interface reserved for future physics.</summary>
    public sealed class PhysicsModule : IRuntimeModule
    {
        public string ModuleId => "physics";
        RuntimeContext _context;

        public void Attach(RuntimeContext context) => _context = context;
        public void Detach() => _context = null;
        public void HandleCommand(RuntimeCommand command) { }
    }
}
