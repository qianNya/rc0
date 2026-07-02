using System.Collections.Generic;

namespace RC0.Runtime.Core
{
    /// <summary>Plugin module contract — each runtime capability implements this.</summary>
    public interface IRuntimeModule
    {
        string ModuleId { get; }
        void Attach(RuntimeContext context);
        void Detach();
        void HandleCommand(RuntimeCommand command);
    }

    public sealed class RuntimeContext
    {
        public RuntimeBootstrap Bootstrap { get; }
        public string SessionId { get; }

        public RuntimeContext(RuntimeBootstrap bootstrap, string sessionId)
        {
            Bootstrap = bootstrap;
            SessionId = sessionId;
        }

        public void EmitEvent(string moduleId, string eventName, Dictionary<string, object> payload)
        {
            Bootstrap.EmitEvent(SessionId, moduleId, eventName, payload);
        }
    }
}
