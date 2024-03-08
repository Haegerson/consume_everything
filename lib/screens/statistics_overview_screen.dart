import 'package:expenso/screens/statistics_screens/barchart_screen.dart';
import 'package:expenso/screens/statistics_screens/linechart_screen.dart';
import 'package:expenso/screens/statistics_screens/piechart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/categories_provider.dart';
import 'package:expenso/hives/categories.dart';

class StatisticsOverviewScreen extends StatefulWidget {
  const StatisticsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsOverviewScreen> createState() =>
      _StatisticsOverviewScreenState();
}

class _StatisticsOverviewScreenState extends State<StatisticsOverviewScreen> {
  final CategoriesProvider _categoriesProvider = CategoriesProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics Overview'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildContainer('LineChart', () async {
              // Retrieve all categories
              List<Categories> categories =
                  await _categoriesProvider.getCategories();
              // Navigate to FlowChartScreen when the first container is clicked
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LineChartScreen(allCategories: categories)),
              );
            }),
            _buildContainer('PieChart', () {
              // Navigate to FlowChartScreen when the first container is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PieChartScreen()),
              );
            }),
            _buildContainer('BarChart', () {
              // Navigate to FlowChartScreen when the first container is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BarChartScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(String text, VoidCallback? onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
// https://pub.dev/packages/fl_chart
// https://pub.dev/packages/syncfusion_flutter_charts