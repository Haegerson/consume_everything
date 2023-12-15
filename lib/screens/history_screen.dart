import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/hives/expenses.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense History'),
      ),
      body: Consumer<ExpensesProvider>(
        builder: (context, expensesProvider, child) {
          return FutureBuilder<List<Expenses>>(
            future: expensesProvider.getExpenses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // If the Future is still running, show a loading indicator
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If the Future completed with an error, show an error message
                return Text('Error: ${snapshot.error}');
              } else {
                // If the Future is completed successfully, build the ListView
                List<Expenses> expenseList = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: expenseList.length,
                  itemBuilder: (context, index) {
                    return ExpenseTile(expense: expenseList[index]);
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final Expenses expense;

  const ExpenseTile({required this.expense, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.category.name),
      subtitle: Text(
          'Amount: \$${expense.amount.toStringAsFixed(2)}\nDate: ${expense.date.toString()}'),
      // You can customize the subtitle to display comment if it's not null
      // and format the date according to your preference.
      onTap: () {
        // Handle tile tap if needed, e.g., navigate to a detailed view
      },
    );
  }
}
