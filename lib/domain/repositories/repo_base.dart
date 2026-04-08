import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:simo_learn/domain/models/paginated.dart';
import 'package:simo_learn/utils/exceptions.dart';

abstract class BaseRepository {
  final http.Client client;

  BaseRepository(this.client);

  Map<String, String> _getHeaders({bool useToken = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (useToken) {

      headers['Authorization'] = 'Bearer token_placeholder';
    }
    return headers;
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw HttpException(response.statusCode, response.body);
    }
  }

  Future<dynamic> read(String endpoint, {bool useToken = false}) async {
    final response = await client
        .get(
          Uri.parse(endpoint),
          headers: _getHeaders(useToken: useToken),
        )
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  Future<List<dynamic>> readAll(String endpoint,
      {bool useToken = false}) async {
    final response = await client
        .get(
          Uri.parse(endpoint),
          headers: _getHeaders(useToken: useToken),
        )
        .timeout(const Duration(seconds: 30));
    final data = await _handleResponse(response);
    return data as List<dynamic>;
  }

  Future<PaginatedData<T>> readAllPaginated<T>(
    String endpoint,
    T Function(Map<String, dynamic>) mapper, {
    int page = 1,
    int pageSize = 20,
    bool useToken = false,
  }) async {
    final uri = Uri.parse(endpoint).replace(queryParameters: {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });
    final response = await client
        .get(
          uri,
          headers: _getHeaders(useToken: useToken),
        )
        .timeout(const Duration(seconds: 30));
    final data = await _handleResponse(response) as Map<String, dynamic>;
    return PaginatedData.fromJson(data, mapper);
  }

  Future<dynamic> createByMap(Map<String, dynamic> data, String endpoint,
      {bool useToken = false}) async {
    final response = await client
        .post(
          Uri.parse(endpoint),
          headers: _getHeaders(useToken: useToken),
          body: json.encode(data),
        )
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  Future<dynamic> updateByMap(Map<String, dynamic> data, String endpoint,
      {bool useToken = false}) async {
    final response = await client
        .put(
          Uri.parse(endpoint),
          headers: _getHeaders(useToken: useToken),
          body: json.encode(data),
        )
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  Future<void> deleteByMap(Map<String, dynamic> data, String endpoint,
      {bool useToken = false}) async {
    final response = await client
        .delete(
          Uri.parse(endpoint),
          headers: _getHeaders(useToken: useToken),
          body: json.encode(data),
        )
        .timeout(const Duration(seconds: 30));
    _handleResponse(response);
  }
}
