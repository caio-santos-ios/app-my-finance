import 'package:finance/core/api/api.dart';
import 'package:finance/models/_response_api.dart';

class OperationRepository {
  final _http = ApiClient();

  Future<ResponseApi> create(Object data) async {
    final response = await _http.dio.post("operations", data: data);
    return ResponseApi.fromJson(response.data);
  }
}
