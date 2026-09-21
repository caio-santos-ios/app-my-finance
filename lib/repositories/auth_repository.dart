import 'package:finance/core/api/api.dart';
import 'package:finance/models/_response_api.dart';
import 'package:finance/models/auth_login.dart';

class AuthRepository {
  final _http = ApiClient();

  Future<ResponseApi> register(Object data) async {
    final response = await _http.dio.post("users", data: data);
    return ResponseApi.fromJson(response.data);
  }
  
  Future<ResponseApi> confirmation(Object data) async {
    final response = await _http.dio.put("users/confirm-account", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<ResponseApi> newCode(Object data) async {
    final response = await _http.dio.post("auth/new-code", data: data);
    return ResponseApi.fromJson(response.data);
  }
  
  Future<ResponseApi> forgotPassword(Object data) async {
    final response = await _http.dio.post("auth/forgot-password", data: data);
    return ResponseApi.fromJson(response.data);
  }
  
  Future<ResponseApi> resetPassword(Object data) async {
    final response = await _http.dio.post("auth/reset-password", data: data);
    return ResponseApi.fromJson(response.data);
  }
  
  Future<AuthLogin> login(Object data) async {
    final response = await _http.dio.post("auth/login", data: data);
    return AuthLogin.fromJson(response.data["data"]);
  }
}
