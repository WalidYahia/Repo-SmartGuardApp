class ApiResponse {
  final String? requestId;
  final DeviceResponseState state;
  final dynamic devicePayload;

  ApiResponse({
    this.requestId,
    required this.state,
    this.devicePayload,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      requestId: json['requestId'],
      state: DeviceResponseState.fromInt(json['state'] ?? 1),
      devicePayload: json['devicePayload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'state': state.value,
      'devicePayload': devicePayload,
    };
  }

  bool get isSuccess => state == DeviceResponseState.ok;
  bool get isError => state == DeviceResponseState.error;

  String get errorMessage {
    if (devicePayload != null) {
      return devicePayload.toString();
    }
    return state.description;
  }
}

enum DeviceResponseState {
  ok(0, 'Success'),
  error(1, 'Error, unit may be not connected'),
  timeout(3, 'Network Timeout'),

  deviceDataIsRequired(5, 'Device Data Is Required'),
  deviceAlreadyRegistered(6, 'Device Already Registered'),
  deviceNameAlreadyRegistered(7, 'Device Name Already Registered'),

  badRequest(4, 'Bad Request'),
  conflict(8, 'Conflict'),
  inchingIntervalValidationError(9, 'Inching Interval Validation Error'),
  emptyPayload(10, 'Empty Payload'),
  noContent(11, 'No Content');

  final int value;
  final String description;

  const DeviceResponseState(this.value, this.description);

  static DeviceResponseState fromInt(int value) {
    return DeviceResponseState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => DeviceResponseState.error,
    );
  }
}