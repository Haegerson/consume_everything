// ignore_for_file: unused_import

import 'package:flutter/material.dart';

class CategoryType {
  static const String consumption = 'consumption';
  static const String savings = 'savings';
  static const String income = 'income';
}

const categoryTypes = [
  CategoryType.consumption,
  CategoryType.savings,
  CategoryType.income
];

Widget getMonthTextByDouble(double m) {
  String text = "";
  switch (m.toInt()) {
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
}

List<Color> colorArray = [
  const Color(0xFFFF6633),
  const Color(0xFFFFB399),
  const Color(0xFFFF33FF),
  const Color(0xFFFFFF99),
  const Color(0xFF00B3E6),
  const Color(0xFFE6B333),
  const Color(0xFF3366E6),
  const Color(0xFF999966),
  const Color(0xFF99FF99),
  const Color(0xFFB34D4D),
  const Color(0xFF80B300),
  const Color(0xFF809900),
  const Color(0xFFE6B3B3),
  const Color(0xFF6680B3),
  const Color(0xFF66991A),
  const Color(0xFFFF99E6),
  const Color(0xFFCCFF1A),
  const Color(0xFFFF1A66),
  const Color(0xFFE6331A),
  const Color(0xFF33FFCC),
  const Color(0xFF66994D),
  const Color(0xFFB366CC),
  const Color(0xFF4D8000),
  const Color(0xFFB33300),
  const Color(0xFFCC80CC),
  const Color(0xFF66664D),
  const Color(0xFF991AFF),
  const Color(0xFFE666FF),
  const Color(0xFF4DB3FF),
  const Color(0xFF1AB399),
  const Color(0xFFE666B3),
  const Color(0xFF33991A),
  const Color(0xFFCC9999),
  const Color(0xFFB3B31A),
  const Color(0xFF00E680),
  const Color(0xFF4D8066),
  const Color(0xFF809980),
  const Color(0xFFE6FF80),
  const Color(0xFF1AFF33),
  const Color(0xFF999933),
  const Color(0xFFFF3380),
  const Color(0xFFCCCC00),
  const Color(0xFF66E64D),
  const Color(0xFF4D80CC),
  const Color(0xFF9900B3),
  const Color(0xFFE64D66),
  const Color(0xFF4DB380),
  const Color(0xFFFF4D4D),
  const Color(0xFF99E6E6),
  const Color(0xFF6666FF)
];

class SelectedYearMonthWidget extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;

  SelectedYearMonthWidget(
      {required this.selectedYear, required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    Widget monthText = getMonthTextByDouble(selectedMonth.toDouble());
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$selectedYear',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 20),
          monthText,
        ],
      ),
    );
  }
}
