using System.Text.Json.Serialization;

namespace SmartGuardApp.Models
{
    public class JsonCommand
    {
        [JsonPropertyName("requestId")]
        public string? RequestId { get; set; }

        [JsonPropertyName("jsonCommandType")]
        public int JsonCommandType { get; set; }

        [JsonPropertyName("commandPayload")]
        public JsonCommandPayload? CommandPayload { get; set; }
    }
}

