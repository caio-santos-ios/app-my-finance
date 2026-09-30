import 'package:finance/core/api/api.dart';
import 'package:finance/models/_response_api.dart';
import 'package:finance/models/category.dart';

class CategoryRepository {
  final _http = ApiClient();

  Future<List<Category>> getSelect([String? type]) async {
    final typeParam = (type != null && type.isNotEmpty) ? "&type=$type" : "";
    final response = await _http.dio.get("categories/select?deleted=false$typeParam");
    return response.statusCode == 200 ? (response.data["data"] as List).map((e) => Category.fromJson(e)).toList() : [];
  }

  Future<ResponseApi> create(Object data) async {
    final response = await _http.dio.post("categories", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<ResponseApi> update(Object data) async {
    final response = await _http.dio.put("categories", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<ResponseApi> delete(String id) async {
    final response = await _http.dio.delete("categories/$id");
    return ResponseApi.fromJson(response.data);
  }
}
