import 'package:finance/models/auth_login.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static void setToken(AuthLogin auth) {
    final box = Hive.box("auth");

    box.put("token", auth.token);
    box.put("refreshToken", auth.refreshToken);
    box.put("name", auth.name);
    box.put("photo", auth.photo);
  }

  static String getToken() {
    final box = Hive.box("auth");

    return box.get("token") ?? "";
  }

  static String getRefreshToken() {
    final box = Hive.box("auth");

    return box.get("refreshToken") ?? "";
  }

  static bool isValidRefreshToken() {
    final box = Hive.box("auth");

    String refreshToken = box.get("refreshToken") ?? "";
    if (refreshToken.isEmpty) return false;

    bool hasExpired = JwtDecoder.isExpired(refreshToken);

    return !hasExpired;
  }
}
