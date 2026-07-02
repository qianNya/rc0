using System.Collections.Generic;

namespace RC0.Runtime.Core
{
    /// <summary>Flutter → Unity command envelope (v1 protocol).</summary>
    public sealed class RuntimeCommand
    {
        public int v;
        public string sessionId;
        public string module;
        public string action;
        public Dictionary<string, object> payload;

        public RuntimeCommand()
        {
            payload = new Dictionary<string, object>();
        }
    }

    /// <summary>Unity → Flutter event envelope.</summary>
    public sealed class RuntimeEvent
    {
        public int v;
        public string sessionId;
        public string module;
        public string eventName;
        public Dictionary<string, object> payload;

        public RuntimeEvent()
        {
            payload = new Dictionary<string, object>();
        }
    }
}
