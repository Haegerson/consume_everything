import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expenso/providers/expense_provider.dart';

class FlowChartScreen extends StatefulWidget {
  const FlowChartScreen({super.key});

  @override
  State<FlowChartScreen> createState() => _FlowChartScreenState();
}

class _FlowChartScreenState extends State<FlowChartScreen> {
  final ExpensesProvider _expensesProvider = ExpensesProvider();
  late Future<Map<String, double>> _monthlyExpenses;

  @override
  void initState() {
    super.initState();
    _monthlyExpenses = _expensesProvider.getMonthlyExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _monthlyExpenses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Map<String, double> monthlyExpenses =
              snapshot.data as Map<String, double>;

          return LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: monthlyExpenses.entries
                      .map((entry) => FlSpot(
                            convertMonthYearToDouble(
                                entry.key), // assuming 'month-year' format
                            entry.value,
                          ))
                      .toList(),
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              titlesData: FlTitlesData(),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: true),
            ),
          );
        }
      },
    );
  }

  // Helper method to convert "MM-yyyy" to a numerical representation
  double convertMonthYearToDouble(String monthYear) {
    List<String> parts = monthYear.split('-');
    int month = int.parse(parts[0]);
    int year = int.parse(parts[1]);
    return month + (year * 12).toDouble();
  }
}
