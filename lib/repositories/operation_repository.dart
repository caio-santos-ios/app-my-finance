import 'package:finance/core/api/api.dart';
import 'package:finance/models/_response_api.dart';
import 'package:finance/models/operation.dart';

class OperationRepository {
  final _http = ApiClient();

  Future<List<Operation>> get({String query = ""}) async {
    final response = await _http.dio.get("operations/select?deleted=false&$query");
    return response.statusCode == 200 ? (response.data["data"] as List).map((e) => Operation.fromJson(e)).toList() : [];
  }

  Future<ResponseApi> create(Object data) async {
    final response = await _http.dio.post("operations", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<ResponseApi> update(Object data) async {
    final response = await _http.dio.put("operations", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _http.dio.delete("operations/$id");
  }
}
