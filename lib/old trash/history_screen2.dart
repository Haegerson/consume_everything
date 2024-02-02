import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:expenso/hives/expenses.dart';
import 'package:expenso/hives/incomes.dart';
import 'package:expenso/dropdowns.dart';
import 'package:intl/intl.dart';

class HistoryScreen2 extends StatefulWidget {
  const HistoryScreen2({Key? key}) : super(key: key);
  @override
  State<HistoryScreen2> createState() => _HistoryScreen2State();
}

class _HistoryScreen2State extends State<HistoryScreen2>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, bool> _expansionStates = {};
  ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          buildYearDropdown("Select Year", selectedYear, (int? value) {
            if (value != null) {
              setState(() {
                selectedYear = value;
              });
            }
          }),
          Expanded(
            child: TabBarView(controller: _tabController, children: [
              // Expsenses Tab
              Consumer<ExpensesProvider>(
                builder: (context, expensesProvider, child) {
                  return FutureBuilder<List<Expenses>>(
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
                        List<Expenses> expenseList = snapshot.data!
                            .where((element) =>
                                (element.date.year == selectedYear))
                            .toList();
                        Map<String, List<Expenses>> groupedExpenses =
                            groupByMonth(expenseList);

                        return Scrollable(
                            controller: _scrollController,
                            restorationId: 'expensesScrollable',
                            viewportBuilder:
                                (BuildContext context, ViewportOffset) {
                              return ListView.builder(
                                itemCount: groupedExpenses.length,
                                itemBuilder: (context, index) {
                                  String month =
                                      groupedExpenses.keys.elementAt(index);
                                  List<Expenses> expensesInMonth =
                                      groupedExpenses[month]!.reversed.toList();

                                  return ExpansionTile(
                                    key: UniqueKey(),
                                    title: Text(DateFormat('MMMM yyyy')
                                        .format(expensesInMonth.first.date)),
                                    onExpansionChanged: (bool isExpanded) {
                                      setState(() {
                                        _expansionStates[month] = isExpanded;
                                      });
                                    },
                                    initiallyExpanded:
                                        _expansionStates[month] ?? false,
                                    children: expensesInMonth
                                        .map((expense) => ExpenseTile(
                                              expense: expense,
                                            ))
                                        .toList(),
                                  );
                                },
                              );
                            });
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
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // If the Future completed with an error, show an error message
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // If the Future is completed successfully, build the ListView
                        List<Incomes> incomeList = snapshot.data!
                            .where((element) =>
                                (element.date.year == selectedYear))
                            .toList();
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
          ),
        ],
      ),
    );
  }
}

Map<String, List<Expenses>> groupByMonth(List<Expenses> expenses) {
  Map<String, List<Expenses>> groupedExpenses = {};

  for (Expenses expense in expenses) {
    String month = DateFormat('MMMM', 'en_US').format(expense.date);
    groupedExpenses.putIfAbsent(month, () => []);
    groupedExpenses[month]!.add(expense);
  }

  return groupedExpenses;
}

class ExpenseTile extends StatelessWidget {
  final Expenses expense;

  const ExpenseTile({required this.expense, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle tile tap if needed, e.g., navigate to a detailed view
      },
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              title: Text(expense.category.name),
              subtitle: Text(
                'Amount: \$${expense.amount.toStringAsFixed(2)}\nDate: ${expense.date.toString()}',
              ),
              onTap: () {
                // Handle tile tap if needed, e.g., navigate to a detailed view
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              // Call your method when the bin icon is tapped
              Provider.of<ExpensesProvider>(context, listen: false)
                  .deleteExpense(expense);
            },
            child: Icon(
              Icons.delete,
              color: Colors.red, // You can customize the color as needed
            ),
          ),
        ],
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
