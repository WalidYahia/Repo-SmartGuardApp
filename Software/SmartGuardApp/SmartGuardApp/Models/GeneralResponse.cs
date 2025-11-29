using System.Text.Json.Serialization;

namespace SmartGuardApp.Models
{
    public class GeneralResponse
    {
        [JsonPropertyName("requestId")]
        public string? RequestId { get; set; }

        [JsonPropertyName("state")]
        public int State { get; set; }

        [JsonPropertyName("devicePayload")]
        public object? DevicePayload { get; set; }
    }

    public class LoadAllUnitsResponse : GeneralResponse
    {
        [JsonPropertyName("devicePayload")]
        public new List<Sensor>? DevicePayload { get; set; }
    }
}

