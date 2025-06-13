import 'package:expenso/const/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/expenses_provider.dart';
import 'package:expenso/dropdowns.dart';
import 'package:month_year_picker/month_year_picker.dart';
// https://www.youtube.com/watch?v=rZx_isqXrhg for touch effects

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
      appBar: AppBar(
        title: Text('Piechart'),
      ),
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

              return Column(
                children: [
                  SelectedYearMonthWidget(
                      selectedYear: selectedStartYear,
                      selectedMonth: selectedStartMonth),
                  ElevatedButton(
                    onPressed: () async {
                      await _selectStartYearMonth(context);
                    },
                    child: Text('Select Year and Month'),
                  ),
                  SelectedYearMonthWidget(
                      selectedYear: selectedEndYear,
                      selectedMonth: selectedEndMonth),
                  ElevatedButton(
                    onPressed: () async {
                      await _selectEndYearMonth(context);
                    },
                    child: Text('Select Year and Month'),
                  ),
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

  Future<void> _selectStartYearMonth(BuildContext context) async {
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
        selectedStartYear = selectedDate.year;
        selectedStartMonth = selectedDate.month;
      });
    }
  }

  Future<void> _selectEndYearMonth(BuildContext context) async {
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
        selectedEndYear = selectedDate.year;
        selectedEndMonth = selectedDate.month;
      });
    }
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
