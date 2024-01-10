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
