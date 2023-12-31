import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:expenso/hives/expenses.dart';
import 'package:expenso/hives/incomes.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Expenses'),
            Tab(text: 'Incomes'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        // Expsenses Tab
        Consumer<ExpensesProvider>(
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
        // Incomes Tab
        Consumer<IncomesProvider>(
          builder: (context, incomesProvider, child) {
            return FutureBuilder<List<Incomes>>(
              future: incomesProvider.getIncomes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // If the Future is still running, show a loading indicator
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // If the Future completed with an error, show an error message
                  return Text('Error: ${snapshot.error}');
                } else {
                  // If the Future is completed successfully, build the ListView
                  List<Incomes> incomeList = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: incomeList.length,
                    itemBuilder: (context, index) {
                      return IncomeTile(income: incomeList[index]);
                    },
                  );
                }
              },
            );
          },
        ),
      ]),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final Expenses expense;

  const ExpenseTile({required this.expense, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.key.toString()), // Use a unique key for each tile
      background: Container(
        color: Colors.red, // Set the background color when swiping
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Handle the dismissal here:
        Provider.of<ExpensesProvider>(context, listen: false)
            .deleteExpense(expense);
      },
      child: ListTile(
        title: Text(expense.category.name),
        subtitle: Text(
            'Amount: \$${expense.amount.toStringAsFixed(2)}\nDate: ${expense.date.toString()}'),
        onTap: () {
          // Handle tile tap if needed, e.g., navigate to a detailed view
        },
      ),
    );
  }
}

class IncomeTile extends StatelessWidget {
  final Incomes income;

  const IncomeTile({required this.income, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(income.key.toString()), // Use a unique key for each tile
      background: Container(
        color: Colors.red, // Set the background color when swiping
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Handle the dismissal here:
        Provider.of<IncomesProvider>(context, listen: false)
            .deleteIncome(income);
      },
      child: ListTile(
        title: Text(income.category.name),
        subtitle: Text(
            'Amount: \$${income.amount.toStringAsFixed(2)}\nDate: ${income.date.toString()}'),
        onTap: () {
          // Handle tile tap if needed, e.g., navigate to a detailed view
        },
      ),
    );
  }
}
