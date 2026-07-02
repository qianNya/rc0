using RC0.Runtime.Core;

namespace RC0.Runtime.Modules
{
    /// <summary>URP material management — V1 stub.</summary>
    public sealed class MaterialModule : IRuntimeModule
    {
        public string ModuleId => "material";
        RuntimeContext _context;

        public void Attach(RuntimeContext context) => _context = context;
        public void Detach() => _context = null;
        public void HandleCommand(RuntimeCommand command) { }
    }
}
