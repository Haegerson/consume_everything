import 'package:expenso/const/constants.dart';
import 'package:expenso/providers/categories_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/dropdowns.dart';
import 'package:expenso/hives/categories.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class LineChartScreen extends StatefulWidget {
  final List<Categories>
      allCategories; // only for first call of filling selectedCategories

  const LineChartScreen({super.key, required this.allCategories});

  @override
  State<LineChartScreen> createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  final ExpensesProvider _expensesProvider = ExpensesProvider();
  final IncomesProvider _incomesProvider = IncomesProvider();
  final CategoriesProvider _categoriesProvider = CategoriesProvider();
  late Future<Map<String, double>> _monthlyConsumeExpenses;
  late Future<Map<String, double>> _monthlySavingsExpenses;
  late Future<Map<String, double>> _monthlyIncomes;
  late Future<List<Categories>> _categories;
  late int selectedYear;

  final Gradient consumeExpenseGradient = const LinearGradient(
      colors: [Colors.redAccent, Color.fromARGB(255, 105, 10, 3)]);
  final Gradient savingsExpenseGradient = const LinearGradient(colors: [
    Color.fromARGB(255, 59, 132, 235),
    Color.fromARGB(255, 125, 200, 238)
  ]);
  final Gradient incomeGradient = const LinearGradient(
      colors: [Color.fromARGB(255, 5, 230, 76), Color.fromARGB(255, 2, 60, 7)]);

  // list to store selected category names
  List<String> selectedCategories = [];

//method to update selected categories
  void updateSelectedCategories(List<String> selected) {
    setState(() {
      selectedCategories = selected;
      _monthlyConsumeExpenses = _expensesProvider.getMonthlyExpenses(
          selectedYear, CategoryType.consumption, selectedCategories);
      _monthlySavingsExpenses = _expensesProvider.getMonthlyExpenses(
          selectedYear, CategoryType.savings, selectedCategories);
      _monthlyIncomes = _incomesProvider.getMonthlyIncomes(selectedYear);
    });
  }

  @override
  void initState() {
    super.initState();
    selectedCategories =
        widget.allCategories.map((category) => category.name).toList();
    selectedYear = DateTime.now().year.toInt();
    _monthlyConsumeExpenses = _expensesProvider.getMonthlyExpenses(
        selectedYear, CategoryType.consumption, selectedCategories);
    _monthlySavingsExpenses = _expensesProvider.getMonthlyExpenses(
        selectedYear, CategoryType.savings, selectedCategories);
    _monthlyIncomes = _incomesProvider.getMonthlyIncomes(selectedYear);
    _categories = _categoriesProvider.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Linechart'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          _monthlyConsumeExpenses,
          _monthlySavingsExpenses,
          _monthlyIncomes,
          _categories
        ]), // Use Future.wait to wait for all futures
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            Map<String, double> monthlyConsumeExpenses =
                (snapshot.data as List<dynamic>)[0] as Map<String, double>;
            Map<String, double> monthlySavingsExpenses =
                (snapshot.data as List<dynamic>)[1] as Map<String, double>;
            Map<String, double> monthlyIncomes =
                (snapshot.data as List<dynamic>)[2] as Map<String, double>;
            List<Categories> categories =
                (snapshot.data as List<dynamic>)[3] as List<Categories>;

            List<FlSpot> consumeExpenseSpotList = monthlyConsumeExpenses.entries
                .map((entry) => FlSpot(
                      convertMonthToDouble(
                          entry.key), // assuming 'month' format
                      entry.value,
                    ))
                .toList();
            List<FlSpot> savingsExpenseSpotList = monthlySavingsExpenses.entries
                .map((entry) => FlSpot(
                      convertMonthToDouble(entry.key),
                      entry.value,
                    ))
                .toList();
            List<FlSpot> incomeSpotList = monthlyIncomes.entries
                .map((entry) => FlSpot(
                      convertMonthToDouble(entry.key),
                      entry.value,
                    ))
                .toList();

            return Column(
              children: [
                IconButton(
                  icon: Icon(Icons.filter_list), // Filter symbol icon
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CategorySelectionDialog(
                        categories: categories,
                        selectedCategories: selectedCategories,
                        onCategoriesSelected: updateSelectedCategories,
                      ),
                    );
                  },
                ),
                ExpansionTile(
                  title: Text("Selected Categories"),
                  children: [
                    Wrap(
                      children: selectedCategories
                          .map((categoryName) => Chip(
                                label: Text(categoryName),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child: buildYearDropdown(
                      "Year",
                      selectedYear,
                      (int? value) {
                        if (value != null) {
                          setState(() {
                            selectedYear = value;
                            _monthlyConsumeExpenses =
                                _expensesProvider.getMonthlyExpenses(
                                    selectedYear,
                                    CategoryType.consumption,
                                    selectedCategories);
                            _monthlySavingsExpenses =
                                _expensesProvider.getMonthlyExpenses(
                                    selectedYear,
                                    CategoryType.savings,
                                    selectedCategories);
                            _monthlyIncomes = _incomesProvider
                                .getMonthlyIncomes(selectedYear);
                          });
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: LineChart(
                    LineChartData(
                      minX: 1,
                      maxX: 12,
                      lineBarsData: [
                        LineChartBarData(
                          spots: consumeExpenseSpotList,
                          isCurved: false,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                          gradient: consumeExpenseGradient,
                        ),
                        LineChartBarData(
                          spots: savingsExpenseSpotList,
                          isCurved: false,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                          gradient: savingsExpenseGradient,
                        ),
                        LineChartBarData(
                          spots: incomeSpotList,
                          isCurved: false,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                          gradient: incomeGradient,
                        ),
                      ],
                      titlesData: LineTitles.getTitleData(),
                      borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.lime, width: 1)),
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(
                            color: Colors.lime,
                            strokeWidth: 1,
                          );
                        },
                        drawVerticalLine: true,
                        getDrawingVerticalLine: (value) {
                          return const FlLine(
                            color: Colors.lime,
                            strokeWidth: 1,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // Helper method to convert "MM" to a numerical representation
  double convertMonthToDouble(String month) {
    return double.parse(month);
  }
}

class LineTitles {
  static getTitleData() => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return getMonthTextByDouble(value);
              }),
        ),
      );
}

class CategorySelectionDialog extends StatefulWidget {
  final List<Categories> categories;
  final List<String> selectedCategories;
  final ValueChanged<List<String>> onCategoriesSelected;

  const CategorySelectionDialog({
    Key? key,
    required this.categories,
    required this.selectedCategories,
    required this.onCategoriesSelected,
  }) : super(key: key);

  @override
  _CategorySelectionDialogState createState() =>
      _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _selectedCategories.addAll(widget.selectedCategories);
  }

  void _toggleCategory(String category, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedCategories.add(category);
      } else {
        _selectedCategories.remove(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Categories"),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.categories
              .map(
                (category) => CheckboxListTile(
                  value: _selectedCategories.contains(category.name),
                  title: Text(category.name),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) =>
                      _toggleCategory(category.name, isChecked!),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCategoriesSelected(_selectedCategories);
            Navigator.of(context).pop();
          },
          child: const Text("Apply filter"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
