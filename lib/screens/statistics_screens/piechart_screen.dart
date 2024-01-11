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
                  Expanded(
                    child: PieChart(PieChartData(
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
    double percentage = data['percentage'];
    double absoluteValue = data['absoluteValue'];

    Color color = colorArray[colorIndex % colorArray.length];
    colorIndex++;

    sections.add(
      PieChartSectionData(
        color: color,
        value: percentage,
        title: '$percentage%', // Display percentage as the title
        radius: 50, // Set your desired radius here
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      ),
    );
  });

  return sections;
}
