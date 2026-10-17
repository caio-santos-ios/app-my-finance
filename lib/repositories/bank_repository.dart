import 'package:finance/core/api/api.dart';
import 'package:finance/models/_response_api.dart';
import 'package:finance/models/bank.dart';

class BankRepository {
  final _http = ApiClient();

  Future<List<Bank>> getSelect() async {
    final response = await _http.dio.get("banks/select?deleted=false");
    return response.statusCode == 200
        ? (response.data["data"] as List).map((e) => Bank.fromJson(e)).toList()
        : [];
  }

  Future<List<Bank>> getTypeBanks() async {
    final response = await _http.dio.get(
      "generic-tables/select?deleted=false&table=types-banks",
    );
    return response.statusCode == 200
        ? (response.data["data"] as List).map((e) => Bank.fromJson(e)).toList()
        : [];
  }

  Future<ResponseApi> create(Object data) async {
    final response = await _http.dio.post("banks", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<ResponseApi> update(Object data) async {
    final response = await _http.dio.put("banks", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<ResponseApi> delete(String id) async {
    final response = await _http.dio.delete("banks/$id");
    return ResponseApi.fromJson(response.data);
  }
}
