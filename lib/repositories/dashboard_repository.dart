import 'package:finance/core/api/api.dart';
import 'package:finance/models/dashboard.dart';

class DashboardRepository {
  final _http = ApiClient();

  Future<Dashboard?> get(DateTime startDate, DateTime endDate) async {
    final response = await _http.dio.get("dashboard?startDate=$startDate&endDate=$endDate");
    return response.statusCode == 200
        ? Dashboard.fromJson(response.data["data"])
        : null;
  }
}
