using RC0.Runtime.Core;

namespace RC0.Runtime.Modules
{
    public sealed class AssetStreamingModule : IRuntimeModule
    {
        public string ModuleId => "assetStreaming";
        RuntimeContext _context;

        public void Attach(RuntimeContext context) => _context = context;
        public void Detach() => _context = null;

        public void HandleCommand(RuntimeCommand command)
        {
            // V1: CharacterModule resolves paths; future CDN streaming here.
        }
    }
}
