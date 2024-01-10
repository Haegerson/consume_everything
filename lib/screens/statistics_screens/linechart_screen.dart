import 'package:expenso/const/constants.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expenso/providers/expense_provider.dart';

class LineChartScreen extends StatefulWidget {
  const LineChartScreen({super.key});

  @override
  State<LineChartScreen> createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  final ExpensesProvider _expensesProvider = ExpensesProvider();
  final IncomesProvider _incomesProvider = IncomesProvider();
  late Future<Map<String, double>> _monthlyConsumeExpenses;
  late Future<Map<String, double>> _monthlySavingsExpenses;
  late Future<Map<String, double>> _monthlyIncomes;
  late int selectedYear;

  final Gradient consumeExpenseGradient = const LinearGradient(
      colors: [Colors.redAccent, Color.fromARGB(255, 105, 10, 3)]);
  final Gradient savingsExpenseGradient = const LinearGradient(colors: [
    Color.fromARGB(255, 59, 132, 235),
    Color.fromARGB(255, 125, 200, 238)
  ]);
  final Gradient incomeGradient = const LinearGradient(
      colors: [Color.fromARGB(255, 5, 230, 76), Color.fromARGB(255, 2, 60, 7)]);

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year.toInt();
    _monthlyConsumeExpenses = _expensesProvider.getMonthlyExpenses(
        selectedYear, CategoryType.consumption);
    _monthlySavingsExpenses = _expensesProvider.getMonthlyExpenses(
        selectedYear, CategoryType.savings);
    _monthlyIncomes = _incomesProvider.getMonthlyIncomes(selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          _monthlyConsumeExpenses,
          _monthlySavingsExpenses,
          _monthlyIncomes
        ]), // Use Future.wait to wait for both futures
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

            List<FlSpot> consumeExpenseSpotList = monthlyConsumeExpenses.entries
                .map((entry) => FlSpot(
                      convertMonthToDouble(
                          entry.key), // assuming 'month' format
                      entry.value,
                    ))
                .toList();
            List<FlSpot> savingsExpenseSpotList = monthlySavingsExpenses.entries
                .map((entry) => FlSpot(
                      convertMonthToDouble(
                          entry.key), // assuming 'month' format
                      entry.value,
                    ))
                .toList();
            List<FlSpot> incomeSpotList = monthlyIncomes.entries
                .map((entry) => FlSpot(
                      convertMonthToDouble(
                          entry.key), // assuming 'month' format
                      entry.value,
                    ))
                .toList();

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child: DropdownButton<int>(
                      value: selectedYear,
                      items: List.generate(
                        DateTime.now().year - 2019,
                        (index) => DropdownMenuItem<int>(
                          value: 2020 + index,
                          child: Text((2020 + index).toString()),
                        ),
                      ),
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            selectedYear = value;
                            _monthlyConsumeExpenses =
                                _expensesProvider.getMonthlyExpenses(
                                    selectedYear, CategoryType.consumption);
                            _monthlySavingsExpenses =
                                _expensesProvider.getMonthlyExpenses(
                                    selectedYear, CategoryType.savings);
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
