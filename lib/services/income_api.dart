import 'dart:convert';
import 'package:expenso/models/income.dart';
import 'package:expenso/services/api_client.dart';

class IncomeApi {
  final ApiClient _client;
  IncomeApi(this._client);

  Future<List<Income>> fetchAll() async {
    final res = await _client.get('incomes');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Income.fromJson(e)).toList();
    }
    throw Exception('Failed to load incomes');
  }

  Future<Income> create(Income inc) async {
    final res = await _client.post('incomes', body: {
      'category_id': inc.categoryId,
      'amount': inc.amount,
      'comment': inc.comment,
      'date': inc.date.toIso8601String(),
    });
    if (res.statusCode == 201) {
      return Income.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create income');
  }

  Future<void> delete(int id) async {
    final res = await _client.delete('incomes/$id');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete income');
    }
  }
}
