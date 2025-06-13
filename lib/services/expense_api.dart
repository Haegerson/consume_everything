import 'dart:convert';
import 'package:expenso/models/expense.dart';
import 'package:expenso/services/api_client.dart';

class ExpenseApi {
  final ApiClient _client;
  ExpenseApi(this._client);

  Future<List<Expense>> fetchAll() async {
    final res = await _client.get('expenses');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    }
    throw Exception('Failed to load expenses');
  }

  Future<Expense> create(Expense exp) async {
    final res = await _client.post('expenses', body: {
      'category_id': exp.categoryId,
      'amount': exp.amount,
      'comment': exp.comment,
      'date': exp.date.toIso8601String(),
    });
    if (res.statusCode == 201) {
      return Expense.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create expense');
  }

  Future<void> delete(int id) async {
    final res = await _client.delete('expenses/$id');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete expense');
    }
  }
}
