import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/expenses_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:expenso/const/constants.dart';
import 'package:expenso/models/category.dart';
import 'package:expenso/models/expense.dart';
import 'package:expenso/models/income.dart';
import 'package:expenso/providers/categories_provider.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback refreshCallback;
  const HistoryScreen({
    Key? key,
    required this.refreshCallback,
  }) : super(key: key);
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    VoidCallback refreshCallback = widget.refreshCallback;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Expenses'),
            const Tab(text: 'Incomes'),
          ],
        ),
      ),
      body: Column(
        children: [
          SelectedYearMonthWidget(
              selectedYear: selectedYear, selectedMonth: selectedMonth),
          ElevatedButton(
            onPressed: () async {
              await _selectYearMonth(context);
            },
            child: Text('Select Year and Month'),
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: [
              // Expenses Tab
              Consumer<ExpensesProvider>(
                builder: (context, expensesProvider, child) {
                  return FutureBuilder<List<Expense>>(
                    future: expensesProvider.getExpenses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // If the Future is still running, show a loading indicator
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // If the Future completed with an error, show an error message
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // If the Future is completed successfully, build the ListView
                        List<Expense> expenseList = snapshot.data!
                            .where((element) =>
                                (element.date.year == selectedYear &&
                                    element.date.month == selectedMonth))
                            .toList();
                        return ListView.builder(
                          itemCount: expenseList.length,
                          itemBuilder: (context, index) {
                            return ExpenseTile(
                              expense: expenseList[index],
                              onTileMovedCallback: () {
                                // Do something when tile is moved
                              },
                              refreshCallback: refreshCallback,
                            );
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
                  return FutureBuilder<List<Income>>(
                    future: incomesProvider.getIncomes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // If the Future is still running, show a loading indicator
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // If the Future completed with an error, show an error message
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // If the Future is completed successfully, build the ListView
                        List<Income> incomeList = snapshot.data!
                            .where((element) =>
                                (element.date.year == selectedYear))
                            .toList();
                        return ListView.builder(
                          itemCount: incomeList.length,
                          itemBuilder: (context, index) {
                            return IncomeTile(
                              income: incomeList[index],
                              refreshCallback: refreshCallback,
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _selectYearMonth(BuildContext context) async {
    Locale localeObj = const Locale("en");
    DateTime? selectedDate = await showMonthYearPicker(
      locale: localeObj,
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      //locale: Locale("en"),
    );

    if (selectedDate != null) {
      setState(() {
        selectedYear = selectedDate.year;
        selectedMonth = selectedDate.month;
      });
    }
  }
}

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTileMovedCallback;
  final VoidCallback refreshCallback;

  const ExpenseTile(
      {required this.expense,
      required this.onTileMovedCallback,
      required this.refreshCallback,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    return Dismissible(
      key: ValueKey(expense.id), // Use a unique key for each tile
      background: Container(
        color: Colors.red, // Set the background color when swiping
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Handle the dismissal here:
        Provider.of<ExpensesProvider>(context, listen: false)
            .deleteExpense(expense.id!);
        refreshCallback();
      },
      onUpdate: (details) {
        onTileMovedCallback();
      },
      child: ListTile(
        title: Text(
          categProvider.getById(expense.categoryId).name,
        ),
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
  final Income income;
  final VoidCallback refreshCallback;

  const IncomeTile(
      {required this.income, required this.refreshCallback, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    return Dismissible(
      key: ValueKey(income.id), // Use a unique key for each tile
      background: Container(
        color: Colors.red, // Set the background color when swiping
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Handle the dismissal here:
        Provider.of<IncomesProvider>(context, listen: false)
            .deleteIncome(income.id!);
        refreshCallback();
      },
      child: ListTile(
        title: Text(categProvider.getById(income.categoryId).name),
        subtitle: Text(
            'Amount: \$${income.amount.toStringAsFixed(2)}\nDate: ${income.date.toString()}'),
        onTap: () {
          // Handle tile tap if needed, e.g., navigate to a detailed view
        },
      ),
    );
  }
}
