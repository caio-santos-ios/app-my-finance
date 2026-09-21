import 'package:finance/core/api/api.dart';
import 'package:finance/models/bank.dart';

class BankRepository {
  final _http = ApiClient();

  Future<List<Bank>> getSelect() async {
    final response = await _http.dio.get("banks/select?deleted=false");
    return response.statusCode == 200 ? (response.data["data"] as List).map((e) => Bank.fromJson(e)).toList() : [];
  }
}
