import 'package:expenso/const/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/expense_provider.dart';

class PieChartScreen extends StatefulWidget {
  const PieChartScreen({super.key});

  @override
  State<PieChartScreen> createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  final ExpensesProvider _expensesProvider = ExpensesProvider();
  late int selectedStartYear;
  late int selectedStartMonth;
  late int selectedEndYear;
  late int selectedEndMonth;
  late Future<Map<String, Map<String, dynamic>>> _categoryData;

  @override
  void initState() {
    super.initState();
    selectedStartYear = DateTime.now().year.toInt();
    selectedEndYear = DateTime.now().year.toInt();
    selectedStartMonth = DateTime.now().month.toInt();
    selectedEndMonth = DateTime.now().month.toInt();
    _categoryData = _expensesProvider.calculateCategoryPercentagesBetween(
        selectedStartYear,
        selectedStartMonth,
        selectedEndYear,
        selectedEndMonth);
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> _generateYearDropdownItems() {
      int currentYear = DateTime.now().year;
      List<DropdownMenuItem<int>> items = [];

      for (int year = currentYear; year >= 2020; year--) {
        items.add(DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString()),
        ));
      }

      return items;
    }

    List<DropdownMenuItem<int>> _generateMonthDropdownItems() {
      List<DropdownMenuItem<int>> items = [];

      for (int month = 1; month <= 12; month++) {
        items.add(DropdownMenuItem<int>(
          value: month,
          child: Text(month.toString()),
        ));
      }

      return items;
    }

    Widget _buildYearDropdown(
        String label, int value, Function(int?) onChanged) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<int>(
          value: value,
          items: _generateYearDropdownItems(),
          onChanged: onChanged,
          hint: Text(label),
        ),
      );
    }

    Widget _buildMonthDropdown(
        String label, int value, void Function(int?) onChanged) {
      return Container(
        padding: EdgeInsets.all(8.0),
        child: DropdownButton<int>(
          value: value,
          items: _generateMonthDropdownItems(),
          onChanged: onChanged,
          hint: Text(label),
        ),
      );
    }

    void _refreshChart() {
      setState(() {
        _categoryData = _expensesProvider.calculateCategoryPercentagesBetween(
            selectedStartYear,
            selectedStartMonth,
            selectedEndYear,
            selectedEndMonth);
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
                  _buildYearDropdown("Start Year", selectedStartYear,
                      (int? value) {
                    setState(() {
                      if (value != null) {
                        selectedStartYear = value;
                      }
                    });
                  }),
                  _buildMonthDropdown("Start Month", selectedStartMonth,
                      (int? value) {
                    if (value != null) {
                      setState(() {
                        selectedStartMonth = value;
                      });
                    }
                  }),
                  _buildYearDropdown("End Year", selectedEndYear, (int? value) {
                    if (value != null) {
                      setState(() {
                        selectedEndYear = value;
                      });
                    }
                  }),
                  _buildMonthDropdown("End Month", selectedEndMonth,
                      (int? value) {
                    if (value != null) {
                      setState(() {
                        selectedEndMonth = value;
                      });
                    }
                  }),
                  ElevatedButton(
                    onPressed: () {
                      _refreshChart();
                    },
                    child: Text("Calculate!"),
                  ),
                  Expanded(
                    child: PieChart(PieChartData(
                      centerSpaceRadius: 0,
                      sections: getSections(
                          selectedStartYear,
                          selectedStartMonth,
                          selectedEndYear,
                          selectedEndMonth,
                          categoryData),
                    )),
                  )
                ],
              );
            }
          }),
    );
  }
}

List<PieChartSectionData> getSections(int startYear, int startMonth,
    int endYear, int endMonth, Map<String, Map<String, dynamic>> categoryData) {
  List<PieChartSectionData> sections = [];
  int colorIndex = 0;

  categoryData.forEach((category, data) {
    double percentage = double.parse(data['percentage'].toStringAsFixed(1));
    double absoluteValue =
        double.parse(data['absoluteValue'].toStringAsFixed(1));

    Color color = colorArray[colorIndex % colorArray.length];
    colorIndex++;

    sections.add(
      PieChartSectionData(
        color: color,
        value: percentage,
        title: "$category:\n $absoluteValue€",
        // "$absoluteValue€ ($percentage%)", // Display percentage as the title
        radius: 120, // Set your desired radius here
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
        titlePositionPercentageOffset: 1.2,
      ),
    );
  });

  return sections;
}
