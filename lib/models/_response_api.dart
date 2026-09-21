class ResponseApi {
  final String message;

  ResponseApi({required this.message});

  factory ResponseApi.fromJson(Map<String, dynamic> json) {
    return ResponseApi(message: json["message"]);
  }
}
