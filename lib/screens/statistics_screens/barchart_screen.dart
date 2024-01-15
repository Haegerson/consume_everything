import 'package:expenso/const/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/dropdowns.dart';

class BarChartScreen extends StatefulWidget {
  const BarChartScreen({super.key});

  @override
  State<BarChartScreen> createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  final ExpensesProvider _expensesProvider = ExpensesProvider();
  late int selectedYear;
  late int selectedMonth;
  late Future<Map<String, Map<String, dynamic>>> _categoryData;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year.toInt();
    selectedMonth = DateTime.now().month.toInt();

    _categoryData = _expensesProvider.calculateCategoryPercentagesBetween(
        selectedYear, selectedMonth, selectedYear, selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    void _refreshChart() {
      setState(() {
        _categoryData = _expensesProvider.calculateCategoryPercentagesBetween(
            selectedYear, selectedMonth, selectedYear, selectedMonth);
      });
      print(_categoryData);
    }

    return Scaffold(
      body: FutureBuilder(
          future: _categoryData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              Map<String, Map<String, dynamic>> categoryData =
                  snapshot.data as Map<String, Map<String, dynamic>>;
              print(categoryData);

              return Column(
                children: [
                  buildYearDropdown("Start Year", selectedYear, (int? value) {
                    setState(() {
                      if (value != null) {
                        selectedYear = value;
                      }
                    });
                  }),
                  buildMonthDropdown("Start Month", selectedMonth,
                      (int? value) {
                    setState(() {
                      if (value != null) {
                        selectedMonth = value;
                      }
                    });
                  }),
                  ElevatedButton(
                    onPressed: () {
                      _refreshChart();
                    },
                    child: Text("Calculate!"),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BarChart(
                        BarChartData(
                          groupsSpace: 10,
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return getCategoryName(
                                      value.toInt(), categoryData);
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          barGroups: createBarGroups(categoryData),
                          extraLinesData: ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: 10, // Set your threshold value
                                color: Colors.red, // Color of the line
                                strokeWidth: 2, // Width of the line
                                dashArray: [5, 5], // Optional dash pattern
                              ),
                              HorizontalLine(
                                y: 20, // Set another threshold value
                                color: Colors.blue, // Color of the line
                                strokeWidth: 2, // Width of the line
                                dashArray: [5, 5], // Optional dash pattern
                              ),
                              // Add more lines as needed
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }

  List<BarChartGroupData> createBarGroups(
      Map<String, Map<String, dynamic>> categoryData) {
    List<BarChartGroupData> barGroups = [];
    int i = 0;

    for (String category in categoryData.keys) {
      double value = categoryData[category]!['absoluteValue'];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: colorArray[i % colorArray.length],
              width: 30,
            ),
          ],
        ),
      );
      i++;
    }

    return barGroups;
  }

  Widget getCategoryName(
      int index, Map<String, Map<String, dynamic>> categoryData) {
    List<String> categories = getCategoryNames(categoryData);
    return Text(
      categories[index],
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  List<String> getCategoryNames(
      Map<String, Map<String, dynamic>> categoryData) {
    return categoryData.keys.toList();
  }
}
