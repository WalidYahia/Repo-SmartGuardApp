namespace SmartGuardApp.Models
{
    public enum DeviceResponseState
    {
        OK = 0,
        Error = 1,
        NotFound = 2,
        Timeout = 3,
        BadRequest = 4,
        DeviceDataIsRequired = 5,
        DeviceAlreadyRegistered = 6,
        DeviceNameAlreadyRegistered = 7,
        Conflict = 8,
        InchingIntervalValidationError = 9,
        EmptyPayload = 10,
        NoContent = 11
    }
}

