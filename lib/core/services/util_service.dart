import 'package:dio/dio.dart';
import 'package:finance/core/widgets/toastify_widget.dart';
import 'package:finance/pages/auth/login_page.dart';
import 'package:flutter/material.dart';

class UtilService {
  static void normalizeError(BuildContext context, DioException err) {
    if (err.response == null) {
      print(err);
      Toastfy.show(context, "Falha interna", "error");
    } else {
      int status = err.response?.statusCode ?? 400;
      if (status == 401) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }

      if (err.response != null) {
        print(err.response);
        print(err.error);
        print(err.message);
        Toastfy.show(
          context,
          err.response?.data["message"],
          status > 204 ? "warning" : "success",
        );
      }
    }
  }
}
