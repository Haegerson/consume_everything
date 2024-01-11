import 'package:expenso/screens/statistics_screens/linechart_screen.dart';
import 'package:expenso/screens/statistics_screens/piechart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsOverviewScreen extends StatefulWidget {
  const StatisticsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsOverviewScreen> createState() =>
      _StatisticsOverviewScreenState();
}

class _StatisticsOverviewScreenState extends State<StatisticsOverviewScreen> {
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
            _buildContainer('Chart', () {
              // Navigate to FlowChartScreen when the first container is clicked
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LineChartScreen()),
              );
            }),
            _buildContainer('Chart', () {
              // Navigate to FlowChartScreen when the first container is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PieChartScreen()),
              );
            }),
            _buildContainer('Container 3', () {}),
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