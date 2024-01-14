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
                  ElevatedButton(
                    onPressed: () {
                      _refreshChart();
                    },
                    child: Text("Calculate!"),
                  ),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        groupsSpace: 20,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              //rotateAngle: 45,
                              getTitlesWidget: (value, meta) {
                                return getCategoryName(
                                    value.toInt(), categoryData);
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        barGroups: createBarGroups(categoryData),
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
    List<String> categories = getCategoryNames(categoryData);
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
