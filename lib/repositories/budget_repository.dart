import 'package:finance/core/api/api.dart';
import 'package:finance/models/_response_api.dart';
import 'package:finance/models/budget.dart';

class BudgetRepository {
  final _http = ApiClient();

  Future<List<Budget>> get({String query = ""}) async {
    final response = await _http.dio.get("budgets?deleted=false&$query");
    if (response.statusCode == 200 && response.data != null) {
      final dynamic rawData = response.data["data"]["data"];
      if (rawData is List) {
        return rawData.map((e) => Budget.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<Budget?> getById(String id) async {
    final response = await _http.dio.get("budgets/$id");
    if (response.statusCode == 200 && response.data != null) {
      final dynamic rawData = response.data["data"];
      if (rawData != null) {
        return Budget.fromJson(rawData);
      }
    }
    return null;
  }

  Future<ResponseApi> create(Object data) async {
    final response = await _http.dio.post("budgets", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<ResponseApi> update(Object data) async {
    final response = await _http.dio.put("budgets", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _http.dio.delete("budgets/$id");
  }
}
