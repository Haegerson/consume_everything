import 'dart:convert';
import 'package:expenso/models/category.dart';
import 'package:expenso/services/api_client.dart';

class CategoryApi {
  final ApiClient _client;
  CategoryApi(this._client);

  Future<List<Category>> fetchAll() async {
    final res = await _client.get('categories');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<Category> create(Category cat) async {
    final res = await _client.post('categories', body: {
      'name': cat.name,
      'type': cat.type,
      'alert_threshold': cat.alertThreshold,
    });
    if (res.statusCode == 201) {
      return Category.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create category');
  }

  Future<void> delete(int id) async {
    final res = await _client.delete('categories/$id');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete category');
    }
  }
}
