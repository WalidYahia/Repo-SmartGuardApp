import 'enums.dart';
export 'enums.dart' show RemoteActionState;

class ApiResponse {
  final String? requestId;
  final RemoteActionState state;
  final dynamic devicePayload;

  ApiResponse({
    this.requestId,
    required this.state,
    this.devicePayload,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      requestId: json['requestId'],
      state: RemoteActionState.fromJson(json['state'] ?? 1),
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

  bool get isSuccess => state == RemoteActionState.ok;
  bool get isError => state == RemoteActionState.error;

  String get errorMessage {
    if (devicePayload != null) return devicePayload.toString();
    return state.description;
  }
}
