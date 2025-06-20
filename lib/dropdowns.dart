import 'dart:ffi';

import 'package:expenso/const/constants.dart';
import 'package:expenso/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expenso/providers/expenses_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';

import 'package:expenso/models/category.dart';
import 'package:expenso/models/expense.dart';
import 'package:expenso/models/income.dart';

class DropdownCategoryNames extends StatefulWidget {
  final Function(String) onCategorySelected;
  final bool isExpense;
  const DropdownCategoryNames({
    Key? key,
    required this.onCategorySelected,
    required this.isExpense,
  }) : super(key: key);

  @override
  State<DropdownCategoryNames> createState() => DropdownCategoryNamesState();
}

class DropdownCategoryNamesState extends State<DropdownCategoryNames> {
  void updateCategories() {
    setState(() {
      // Perform any logic needed to update the dropdown values
      // For example, you can fetch the categories again.
      categoryNamesFuture = fetchCategoryNames();
    });
  }

  late String? dropDownValue;
  late Future<List<String>> categoryNamesFuture;

  @override
  void initState() {
    super.initState();
    categoryNamesFuture =
        fetchCategoryNames(); // Trigger fetching category names
    dropDownValue = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: categoryNamesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No categories available.');
        } else {
          List<String> categoryNames = snapshot.data!;
          print("First category name is:" + categoryNames[0]);
          print(dropDownValue);

          return DropdownButton<String>(
            value: dropDownValue,
            icon: null,
            items: categoryNames.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                dropDownValue = newValue!;
                widget.onCategorySelected(newValue);
              });
            },
          );
        }
      },
    );
  }

  Future<List<String>> fetchCategoryNames() async {
    CategoriesProvider categProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    List<Category> categories = await categProvider.getCategories();
    List<String> categoryNames = widget.isExpense
        ? categories
            .where((element) =>
                (element.type == CategoryType.consumption) ||
                (element.type == CategoryType.savings))
            .map((element) => element.name)
            .toList()
        : categories
            .where((element) => element.type == CategoryType.income)
            .map((element) => element.name)
            .toList();

    // If dropDownValue is empty, set it to the first value in categoryNames
    print("category names defined in method...");
    if (dropDownValue == null && categoryNames.isNotEmpty) {
      print("now dropdown value is set");
      setState(() {
        dropDownValue = categoryNames.first;
      });
    }

    return categoryNames;
  }
}

class DropdownCategoryTypes extends StatefulWidget {
  final Function(String) onTypeSelected;

  const DropdownCategoryTypes({
    Key? key,
    required this.onTypeSelected, // Callnack for selected Category!
  }) : super(key: key);

  @override
  State<DropdownCategoryTypes> createState() => _DropdownCategoryTypesState();
}

class _DropdownCategoryTypesState extends State<DropdownCategoryTypes> {
  String selectedType =
      categoryTypes[0]; // Initialize with the first category type

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedType,
      onChanged: (String? newValue) {
        if (newValue != null) {
          // Update the selectedType when the dropdown changes
          setState(() {
            selectedType = newValue;
            widget.onTypeSelected(newValue!); // Notify the parent widget
          });
        }
      },
      items: categoryTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
    );
  }
}

List<DropdownMenuItem<int>> generateYearDropdownItems() {
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

List<DropdownMenuItem<int>> generateMonthDropdownItems() {
  List<DropdownMenuItem<int>> items = [];

  for (int month = 1; month <= 12; month++) {
    items.add(DropdownMenuItem<int>(
      value: month,
      child: Text(month.toString()),
    ));
  }

  return items;
}

Widget buildMonthDropdown(
    String label, int value, void Function(int?) onChanged) {
  return Container(
    padding: EdgeInsets.all(8.0),
    child: DropdownButton<int>(
      value: value,
      items: generateMonthDropdownItems(),
      onChanged: onChanged,
      hint: Text(label),
    ),
  );
}

Widget buildYearDropdown(String label, int value, Function(int?) onChanged) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    child: DropdownButton<int>(
      value: value,
      items: generateYearDropdownItems(),
      onChanged: onChanged,
      hint: Text(label),
    ),
  );
}
