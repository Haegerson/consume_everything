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
  Color(0xFFFF6633),
  Color(0xFFFFB399),
  Color(0xFFFF33FF),
  Color(0xFFFFFF99),
  Color(0xFF00B3E6),
  Color(0xFFE6B333),
  Color(0xFF3366E6),
  Color(0xFF999966),
  Color(0xFF99FF99),
  Color(0xFFB34D4D),
  Color(0xFF80B300),
  Color(0xFF809900),
  Color(0xFFE6B3B3),
  Color(0xFF6680B3),
  Color(0xFF66991A),
  Color(0xFFFF99E6),
  Color(0xFFCCFF1A),
  Color(0xFFFF1A66),
  Color(0xFFE6331A),
  Color(0xFF33FFCC),
  Color(0xFF66994D),
  Color(0xFFB366CC),
  Color(0xFF4D8000),
  Color(0xFFB33300),
  Color(0xFFCC80CC),
  Color(0xFF66664D),
  Color(0xFF991AFF),
  Color(0xFFE666FF),
  Color(0xFF4DB3FF),
  Color(0xFF1AB399),
  Color(0xFFE666B3),
  Color(0xFF33991A),
  Color(0xFFCC9999),
  Color(0xFFB3B31A),
  Color(0xFF00E680),
  Color(0xFF4D8066),
  Color(0xFF809980),
  Color(0xFFE6FF80),
  Color(0xFF1AFF33),
  Color(0xFF999933),
  Color(0xFFFF3380),
  Color(0xFFCCCC00),
  Color(0xFF66E64D),
  Color(0xFF4D80CC),
  Color(0xFF9900B3),
  Color(0xFFE64D66),
  Color(0xFF4DB380),
  Color(0xFFFF4D4D),
  Color(0xFF99E6E6),
  Color(0xFF6666FF)
];
