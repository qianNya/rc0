using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace RC0.Runtime.Core
{
    /// <summary>Minimal JSON helpers for Flutter ↔ Unity v1 protocol (no external deps).</summary>
    public static class RuntimeJson
    {
        public static RuntimeCommand ParseCommand(string json)
        {
            if (string.IsNullOrEmpty(json)) return null;

            return new RuntimeCommand
            {
                v = ReadInt(json, "v", 1),
                sessionId = ReadString(json, "sessionId"),
                module = ReadString(json, "module"),
                action = ReadString(json, "action"),
                payload = ParseObject(ReadObjectJson(json, "payload")),
            };
        }

        public static string SerializeEvent(RuntimeEvent runtimeEvent)
        {
            if (runtimeEvent == null) return "{}";

            var sb = new StringBuilder(256);
            sb.Append('{');
            AppendInt(sb, "v", runtimeEvent.v, true);
            AppendString(sb, "sessionId", runtimeEvent.sessionId);
            AppendString(sb, "module", runtimeEvent.module);
            AppendString(sb, "eventName", runtimeEvent.eventName);
            sb.Append("\"payload\":");
            sb.Append(SerializeObject(runtimeEvent.payload));
            sb.Append('}');
            return sb.ToString();
        }

        public static bool ReadBool(Dictionary<string, object> payload, string key, bool fallback = false)
        {
            if (payload == null || !payload.TryGetValue(key, out var value) || value == null)
            {
                return fallback;
            }

            return value switch
            {
                bool b => b,
                string s => s.Equals("true", StringComparison.OrdinalIgnoreCase),
                _ => fallback,
            };
        }

        public static string ReadString(Dictionary<string, object> payload, string key)
        {
            if (payload == null || !payload.TryGetValue(key, out var value) || value == null)
            {
                return null;
            }

            return value as string;
        }

        static Dictionary<string, object> ParseObject(string json)
        {
            var result = new Dictionary<string, object>(StringComparer.Ordinal);
            if (string.IsNullOrEmpty(json) || json == "null") return result;

            var body = json.Trim();
            if (!body.StartsWith("{", StringComparison.Ordinal)) return result;
            body = body.Substring(1, body.Length - 2).Trim();
            if (body.Length == 0) return result;

            var index = 0;
            while (index < body.Length)
            {
                index = SkipWhitespace(body, index);
                if (index >= body.Length) break;

                var key = ReadJsonString(body, ref index);
                index = SkipWhitespace(body, index);
                if (index >= body.Length || body[index] != ':') break;
                index++;
                index = SkipWhitespace(body, index);
                var value = ReadJsonValue(body, ref index);
                if (!string.IsNullOrEmpty(key))
                {
                    result[key] = value;
                }

                index = SkipWhitespace(body, index);
                if (index < body.Length && body[index] == ',') index++;
            }

            return result;
        }

        static string SerializeObject(Dictionary<string, object> payload)
        {
            if (payload == null || payload.Count == 0) return "{}";

            var sb = new StringBuilder(128);
            sb.Append('{');
            var first = true;
            foreach (var pair in payload)
            {
                if (!first) sb.Append(',');
                first = false;
                sb.Append('"').Append(Escape(pair.Key)).Append("\":");
                AppendValue(sb, pair.Value);
            }

            sb.Append('}');
            return sb.ToString();
        }

        static void AppendValue(StringBuilder sb, object value)
        {
            switch (value)
            {
                case null:
                    sb.Append("null");
                    break;
                case bool b:
                    sb.Append(b ? "true" : "false");
                    break;
                case int i:
                    sb.Append(i.ToString(CultureInfo.InvariantCulture));
                    break;
                case long l:
                    sb.Append(l.ToString(CultureInfo.InvariantCulture));
                    break;
                case float f:
                    sb.Append(f.ToString(CultureInfo.InvariantCulture));
                    break;
                case double d:
                    sb.Append(d.ToString(CultureInfo.InvariantCulture));
                    break;
                case string s:
                    sb.Append('"').Append(Escape(s)).Append('"');
                    break;
                case IEnumerable<string> strings:
                    sb.Append('[');
                    var first = true;
                    foreach (var item in strings)
                    {
                        if (!first) sb.Append(',');
                        first = false;
                        sb.Append('"').Append(Escape(item ?? string.Empty)).Append('"');
                    }
                    sb.Append(']');
                    break;
                default:
                    sb.Append('"').Append(Escape(value.ToString())).Append('"');
                    break;
            }
        }

        static void AppendInt(StringBuilder sb, string key, int value, bool first)
        {
            if (!first) sb.Append(',');
            sb.Append('"').Append(key).Append("\":")
                .Append(value.ToString(CultureInfo.InvariantCulture));
        }

        static void AppendString(StringBuilder sb, string key, string value)
        {
            sb.Append(',');
            sb.Append('"').Append(key).Append("\":");
            if (value == null) sb.Append("null");
            else sb.Append('"').Append(Escape(value)).Append('"');
        }

        static string ReadString(string json, string key)
        {
            var pattern = $"\"{key}\"";
            var index = json.IndexOf(pattern, StringComparison.Ordinal);
            if (index < 0) return null;
            index = json.IndexOf(':', index);
            if (index < 0) return null;
            index++;
            index = SkipWhitespace(json, index);
            return ReadJsonString(json, ref index);
        }

        static int ReadInt(string json, string key, int fallback)
        {
            var pattern = $"\"{key}\"";
            var index = json.IndexOf(pattern, StringComparison.Ordinal);
            if (index < 0) return fallback;
            index = json.IndexOf(':', index);
            if (index < 0) return fallback;
            index++;
            index = SkipWhitespace(json, index);
            var end = index;
            while (end < json.Length && (char.IsDigit(json[end]) || json[end] == '-')) end++;
            if (end <= index) return fallback;
            return int.TryParse(json.Substring(index, end - index), NumberStyles.Integer,
                CultureInfo.InvariantCulture, out var value)
                ? value
                : fallback;
        }

        static string ReadObjectJson(string json, string key)
        {
            var pattern = $"\"{key}\"";
            var index = json.IndexOf(pattern, StringComparison.Ordinal);
            if (index < 0) return "{}";
            index = json.IndexOf(':', index);
            if (index < 0) return "{}";
            index++;
            index = SkipWhitespace(json, index);
            if (index >= json.Length) return "{}";

            if (json[index] == '{')
            {
                var depth = 0;
                var start = index;
                for (var i = index; i < json.Length; i++)
                {
                    if (json[i] == '{') depth++;
                    else if (json[i] == '}')
                    {
                        depth--;
                        if (depth == 0) return json.Substring(start, i - start + 1);
                    }
                }
            }

            return "{}";
        }

        static object ReadJsonValue(string json, ref int index)
        {
            index = SkipWhitespace(json, index);
            if (index >= json.Length) return null;

            var ch = json[index];
            if (ch == '"')
            {
                return ReadJsonString(json, ref index);
            }

            if (ch == '{')
            {
                var start = index;
                var depth = 0;
                for (; index < json.Length; index++)
                {
                    if (json[index] == '{') depth++;
                    else if (json[index] == '}')
                    {
                        depth--;
                        if (depth == 0)
                        {
                            index++;
                            return ParseObject(json.Substring(start, index - start));
                        }
                    }
                }

                return new Dictionary<string, object>();
            }

            if (ch == '[')
            {
                var items = new List<string>();
                index++;
                while (index < json.Length)
                {
                    index = SkipWhitespace(json, index);
                    if (index < json.Length && json[index] == ']')
                    {
                        index++;
                        break;
                    }

                    items.Add(ReadJsonString(json, ref index));
                    index = SkipWhitespace(json, index);
                    if (index < json.Length && json[index] == ',') index++;
                }

                return items;
            }

            if (string.Compare(json, index, "true", 0, 4, StringComparison.Ordinal) == 0)
            {
                index += 4;
                return true;
            }

            if (string.Compare(json, index, "false", 0, 5, StringComparison.Ordinal) == 0)
            {
                index += 5;
                return false;
            }

            if (string.Compare(json, index, "null", 0, 4, StringComparison.Ordinal) == 0)
            {
                index += 4;
                return null;
            }

            var end = index;
            while (end < json.Length && "0123456789.-".IndexOf(json[end]) >= 0) end++;
            var numberText = json.Substring(index, end - index);
            index = end;
            if (numberText.Contains("."))
            {
                return double.TryParse(numberText, NumberStyles.Float, CultureInfo.InvariantCulture, out var d)
                    ? d
                    : 0d;
            }

            return int.TryParse(numberText, NumberStyles.Integer, CultureInfo.InvariantCulture, out var i) ? i : 0;
        }

        static string ReadJsonString(string json, ref int index)
        {
            index = SkipWhitespace(json, index);
            if (index >= json.Length || json[index] != '"') return null;
            index++;

            var sb = new StringBuilder();
            while (index < json.Length)
            {
                var ch = json[index++];
                if (ch == '"') break;
                if (ch == '\\' && index < json.Length)
                {
                    var esc = json[index++];
                    switch (esc)
                    {
                        case '"': sb.Append('"'); break;
                        case '\\': sb.Append('\\'); break;
                        case '/': sb.Append('/'); break;
                        case 'b': sb.Append('\b'); break;
                        case 'f': sb.Append('\f'); break;
                        case 'n': sb.Append('\n'); break;
                        case 'r': sb.Append('\r'); break;
                        case 't': sb.Append('\t'); break;
                        case 'u' when index + 3 < json.Length:
                            var hex = json.Substring(index, 4);
                            if (ushort.TryParse(hex, NumberStyles.HexNumber, CultureInfo.InvariantCulture, out var code))
                            {
                                sb.Append((char)code);
                            }
                            index += 4;
                            break;
                        default: sb.Append(esc); break;
                    }
                }
                else
                {
                    sb.Append(ch);
                }
            }

            return sb.ToString();
        }

        static int SkipWhitespace(string json, int index)
        {
            while (index < json.Length && char.IsWhiteSpace(json[index])) index++;
            return index;
        }

        static string Escape(string value)
        {
            if (string.IsNullOrEmpty(value)) return string.Empty;
            return value
                .Replace("\\", "\\\\", StringComparison.Ordinal)
                .Replace("\"", "\\\"", StringComparison.Ordinal)
                .Replace("\n", "\\n", StringComparison.Ordinal)
                .Replace("\r", "\\r", StringComparison.Ordinal)
                .Replace("\t", "\\t", StringComparison.Ordinal);
        }
    }
}
