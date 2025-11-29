using System.Text.Json.Serialization;

namespace SmartGuardApp.Models
{
    public class JsonCommandPayload
    {
        [JsonPropertyName("unitId")]
        public string? UnitId { get; set; }

        [JsonPropertyName("switchNo")]
        public int SwitchNo { get; set; }

        [JsonPropertyName("installedSensorId")]
        public string? InstalledSensorId { get; set; }

        [JsonPropertyName("deviceType")]
        public int DeviceType { get; set; }

        [JsonPropertyName("name")]
        public string? Name { get; set; }

        [JsonPropertyName("inchingTimeInMs")]
        public int InchingTimeInMs { get; set; }
    }
}

