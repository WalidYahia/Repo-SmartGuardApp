using System.Text;
using System.Text.Json;
using SmartGuardApp.Models;

namespace SmartGuardApp.Services
{
    public class ApiService
    {
        private readonly HttpClient _httpClient;
        private const string BaseUrl = "http://192.168.1.4:5000";

        public ApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
            _httpClient.BaseAddress = new Uri(BaseUrl);
            _httpClient.Timeout = TimeSpan.FromSeconds(30);
        }

        public async Task<List<Sensor>> LoadAllUnitsAsync()
        {
            try
            {
                var command = new JsonCommand
                {
                    RequestId = Guid.NewGuid().ToString(),
                    JsonCommandType = (int)JsonCommandType.LoadAllUnits,
                    CommandPayload = new JsonCommandPayload()
                };

                var json = JsonSerializer.Serialize(command);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync("/api/devices/handleUserCommand", content);
                response.EnsureSuccessStatusCode();

                var responseContent = await response.Content.ReadAsStringAsync();
                var generalResponse = JsonSerializer.Deserialize<GeneralResponse>(responseContent, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

                if (generalResponse?.DevicePayload != null && generalResponse.State == (int)DeviceResponseState.OK)
                {
                    // Deserialize the devicePayload as a list of units
                    // DevicePayload is a JsonElement, so we need to serialize it and deserialize as List<Unit>
                    if (generalResponse.DevicePayload is JsonElement jsonElement)
                    {
                        var units = JsonSerializer.Deserialize<List<Sensor>>(jsonElement.GetRawText(), new JsonSerializerOptions
                        {
                            PropertyNameCaseInsensitive = true
                        });
                        return units ?? new List<Sensor>();
                    }
                    else
                    {
                        // Fallback: serialize to string and deserialize
                        var unitsJson = JsonSerializer.Serialize(generalResponse.DevicePayload);
                        var units = JsonSerializer.Deserialize<List<Sensor>>(unitsJson, new JsonSerializerOptions
                        {
                            PropertyNameCaseInsensitive = true
                        });
                        return units ?? new List<Sensor>();
                    }
                }

                return new List<Sensor>();
            }
            catch (Exception ex)
            {
#if DEBUG
                System.Diagnostics.Debug.WriteLine($"Error loading units: {ex.Message}");
#endif
                throw;
            }
        }

        public async Task<bool> ToggleUnitAsync(string unitId, int switchNo, bool turnOn)
        {
            return true;

            try
            {
                var command = new JsonCommand
                {
                    RequestId = Guid.NewGuid().ToString(),
                    JsonCommandType = turnOn ? (int)JsonCommandType.TurnOn : (int)JsonCommandType.TurnOn,
                    CommandPayload = new JsonCommandPayload
                    {
                        UnitId = unitId,
                        SwitchNo = switchNo
                    }
                };

                var json = JsonSerializer.Serialize(command);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync("/api/devices/handleUserCommand", content);
                response.EnsureSuccessStatusCode();

                var responseContent = await response.Content.ReadAsStringAsync();
                var generalResponse = JsonSerializer.Deserialize<GeneralResponse>(responseContent, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

                return generalResponse?.State == (int)DeviceResponseState.OK;
            }
            catch (Exception ex)
            {
#if DEBUG
                System.Diagnostics.Debug.WriteLine($"Error toggling unit: {ex.Message}");
#endif
                return false;
            }
        }
    }
}