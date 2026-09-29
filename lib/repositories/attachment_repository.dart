import 'package:dio/dio.dart';
import 'package:finance/core/api/api.dart';
import 'package:finance/models/_response_api.dart';
import 'package:finance/models/attachment.dart';

class AttachmentRepository {
  final _http = ApiClient();

  Future<List<Attachment>> get({String query = ""}) async {
    final response = await _http.dio.get("attachments/select?deleted=false&$query");
    return response.statusCode == 200 ? (response.data["data"] as List).map((e) => Attachment.fromJson(e)).toList() : [];
  }

  Future<ResponseApi> create(FormData data) async {
    final response = await _http.dio.post("attachments", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<ResponseApi> update(Object data) async {
    final response = await _http.dio.put("attachments", data: data);
    return ResponseApi.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _http.dio.delete("attachments/$id");
  }
}
