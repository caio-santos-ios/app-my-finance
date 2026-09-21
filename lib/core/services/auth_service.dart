import 'package:finance/models/auth_login.dart';
import 'package:hive_flutter/adapters.dart';

class AuthService {
  static void setToken(AuthLogin auth) {
    final box = Hive.box("auth");

    box.put("token", auth.token);
    box.put("name", auth.name);
    box.put("photo", auth.photo);
  }

  static String getToken() {
    final box = Hive.box("auth");

    return box.get("token") ?? "";
  }
}
