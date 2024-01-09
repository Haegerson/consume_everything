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
  late int selectedYear;

  final Gradient gradient = LinearGradient(colors: [Colors.blue, Colors.red]);

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year.toInt();
    _monthlyExpenses = _expensesProvider.getMonthlyExpenses(selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _monthlyExpenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            Map<String, double> monthlyExpenses =
                snapshot.data as Map<String, double>;
            List<FlSpot> expenseSpotList = monthlyExpenses.entries
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
                            _monthlyExpenses = _expensesProvider
                                .getMonthlyExpenses(selectedYear);
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
                          spots: expenseSpotList,
                          isCurved: false,
                          color: Colors.blue,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                          gradient: gradient,
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
                String text = "";
                switch (value.toInt()) {
                  case 1:
                    text = "Jan";
                    break;
                  case 2:
                    text = "Feb";
                    break;
                  case 3:
                    text = "Mar";
                    break;
                  case 4:
                    text = "Apr";
                    break;
                  case 5:
                    text = "May";
                    break;
                  case 6:
                    text = "Jun";
                    break;
                  case 7:
                    text = "Jul";
                    break;
                  case 8:
                    text = "Aug";
                    break;
                  case 9:
                    text = "Sep";
                    break;
                  case 10:
                    text = "Oct";
                    break;
                  case 11:
                    text = "Nov";
                    break;
                  case 12:
                    text = "Dec";
                    break;
                }
                return Text(text);
              }),
        ),
      );
}
