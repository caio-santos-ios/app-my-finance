import 'package:dio/dio.dart';
import 'package:finance/core/api/api.dart';
import 'package:finance/models/user.dart';

class UserRepository {
  final _http = ApiClient();

  Future<User> getMe() async {
    final response = await _http.dio.get('users/me');
    return User.fromJson(response.data['data']);
  }

  Future<User> update(Object data) async {
    final response = await _http.dio.put('users', data: data);
    return User.fromJson(response.data['data']);
  }

  Future<String> updatePhoto(String filePath) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
    });
    final response = await _http.dio.put(
      'users/profile-photo',
      data: formData,
    );
    return response.data['data'] ?? '';
  }

  Future<void> removePhoto() async {
    await _http.dio.put('users/remove-profile-photo', data: FormData());
  }
}
