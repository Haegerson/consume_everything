import 'package:expenso/const/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/providers/categories_provider.dart';
import 'package:expenso/dropdowns.dart';
import 'dart:math';
import 'package:month_year_picker/month_year_picker.dart';

class BarChartScreen extends StatefulWidget {
  const BarChartScreen({super.key});

  @override
  State<BarChartScreen> createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  final ExpensesProvider _expensesProvider = ExpensesProvider();
  final CategoriesProvider _categoriesProvider = CategoriesProvider();
  late int selectedYear;
  late int selectedMonth;
  late Future<Map<String, Map<String, dynamic>>> _categoryData;
  late Future<Map<String, double?>> _categoryThresholds;
  late Future<Map<String, Color>> _categoryColors;
  double maxGlobalThreshold = 0.0;
  bool showThresholdLines = true; // Added boolean variable to toggle thresholds

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year.toInt();
    selectedMonth = DateTime.now().month.toInt();

    _categoryData = _expensesProvider.calculateCategoryPercentagesBetween(
        selectedYear, selectedMonth, selectedYear, selectedMonth);
    _categoryThresholds =
        _categoriesProvider.getCategoryThresholds(CategoryType.consumption);
    _categoryColors = _categoriesProvider.generateCategoryColors();
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
      appBar: AppBar(
        title: Text('Barchart'),
      ),
      body: FutureBuilder(
          future: Future.wait(
              [_categoryData, _categoryThresholds, _categoryColors]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              Map<String, Map<String, dynamic>> categoryData = (snapshot.data
                  as List<dynamic>)[0] as Map<String, Map<String, dynamic>>;
              Map<String, double?> categoryThresholds =
                  (snapshot.data as List<dynamic>)[1] as Map<String, double?>;
              Map<String, Color> categoryColors =
                  (snapshot.data as List<dynamic>)[2] as Map<String, Color>;

              return Column(
                children: [
                  SelectedYearMonthWidget(
                      selectedYear: selectedYear, selectedMonth: selectedMonth),
                  ElevatedButton(
                    onPressed: () async {
                      await _selectYearMonth(context);
                      _refreshChart();
                    },
                    child: Text('Select Year and Month'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Show alert thresholds'),
                      Switch(
                        value: showThresholdLines,
                        onChanged: (value) {
                          setState(() {
                            showThresholdLines = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: BarChart(
                        BarChartData(
                          maxY: calculateMaxYValue(
                              categoryData, categoryThresholds),
                          groupsSpace: 5,
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 40,
                                showTitles: true,
                              ),
                            ),
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
                          barGroups:
                              createBarGroups(categoryData, categoryColors),
                          extraLinesData: ExtraLinesData(
                            horizontalLines: showThresholdLines
                                ? createThresholdLines(categoryData,
                                    categoryThresholds, categoryColors)
                                : [],
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

  Future<void> _selectYearMonth(BuildContext context) async {
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
        selectedYear = selectedDate.year;
        selectedMonth = selectedDate.month;
      });
    }
  }

  List<BarChartGroupData> createBarGroups(
      Map<String, Map<String, dynamic>> categoryData,
      Map<String, Color> categoryColors) {
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
              color: categoryColors[category],
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

List<HorizontalLine> createThresholdLines(
    Map<String, Map<String, dynamic>> categoryData,
    Map<String, double?> categoryThresholds,
    Map<String, Color> categoryColors) {
  List<HorizontalLine> thresholdLines = [];
  int i = 0;
  for (String category in categoryThresholds.keys) {
    double? value = categoryThresholds[category];
    double summedExpenses = 0.0;
    if (categoryData.containsKey(category)) {
      summedExpenses = categoryData[category]!["absoluteValue"];
    }

    if ((value != null) && (summedExpenses > 0.0)) {
      thresholdLines.add(
        HorizontalLine(
          y: value, // Set your threshold value
          color: categoryColors[category], // Color of the line
          strokeWidth: 2, // Width of the line
          dashArray: [5, 5], // Optional dash pattern
        ),
      );
    }
    i++;
  }
  return thresholdLines;
}

double calculateMaxYValue(Map<String, Map<String, dynamic>> categoryData,
    Map<String, double?> categoryThresholds) {
  double maxValue = 0.0;
  for (String category in categoryData.keys) {
    double expenseValue = categoryData[category]!['absoluteValue'];

    double? thresholdValue = categoryThresholds[category];
    double nonNullThresholdValue = 0.0;
    if (thresholdValue != null) {
      nonNullThresholdValue = thresholdValue;
    }
    double localMaximum = max(expenseValue, nonNullThresholdValue);
    if (localMaximum > maxValue) {
      maxValue = localMaximum;
    }
  }
  return maxValue;
}
