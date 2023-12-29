import 'package:expenso/const/constants.dart';
import 'package:expenso/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/hives/incomes.dart';
import 'package:expenso/hives/expenses.dart';
import 'package:expenso/hives/categories.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:expenso/providers/category_data.dart';

class DropdownCategoryNames extends StatefulWidget {
  final Function(String) onCategorySelected;
  const DropdownCategoryNames({
    Key? key,
    required this.onCategorySelected, // Callback for selected Category!
  }) : super(key: key);

  @override
  State<DropdownCategoryNames> createState() => _DropdownCategoryNamesState();
}

class _DropdownCategoryNamesState extends State<DropdownCategoryNames> {
  late String dropDownValue;

  @override
  void initState() {
    super.initState();
    dropDownValue = ''; // Set initial value as needed
    fetchCategoryNames(); // Trigger fetching category names
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchCategoryNames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No categories available.');
        } else {
          List<String> categoryNames = snapshot.data!;

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
                widget
                    .onCategorySelected(newValue!); // Notify the parent widget
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
    List<Categories> categories = await categProvider.getCategories();
    List<String> categoryNames = categories
        .where((element) =>
            (element.type == CategoryType.consumption) ||
            (element.type == CategoryType.savings))
        .map((element) => element.name)
        .toList();

    // If dropDownValue is empty, set it to the first value in categoryNames
    if (dropDownValue.isEmpty && categoryNames.isNotEmpty) {
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
