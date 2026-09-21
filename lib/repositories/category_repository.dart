import 'package:finance/core/api/api.dart';
import 'package:finance/models/category.dart';

class CategoryRepository {
  final _http = ApiClient();

  Future<List<Category>> getSelect(String type) async {
    final response = await _http.dio.get("categories/select?deleted=false&type=$type");
    return response.statusCode == 200 ? (response.data["data"] as List).map((e) => Category.fromJson(e)).toList() : [];
  }
}
