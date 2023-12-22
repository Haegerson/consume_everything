// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:expenso/hives/categories.dart';
import 'package:expenso/hives/expenses.dart';
import 'package:expenso/hives/incomes.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:flutter/material.dart';
import 'package:expenso/const/constants.dart';

class DialogUtils {
  static void showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Category"),
        content: Column(
          children: [
            // Add widgets for additional features here
            // For example:
            TextField(
              decoration: InputDecoration(labelText: 'lalala 1'),
              // Add controller and other properties as needed
            ),
            // Add more widgets as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Add logic to handle additional features
              // For example, update your data or perform other actions
              Navigator.of(context).pop();
            },
            child: Text("Apply"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  static void showAddExpenseDialog(
      BuildContext context,
      List<Categories> categories,
      ExpensesProvider expensesProvider,
      VoidCallback setStateCallback) {
    List<String> categNames = categories
        .where((element) =>
            (element.type == CategoryType.consumption) ||
            (element.type == CategoryType.savings))
        .map((element) => element.name)
        .toList();
    var dropDownValue = categNames.first;
    print(categNames);
    Expenses newExp =
        Expenses(category: categories[0], amount: 0.0, date: DateTime.now());
    TextEditingController amountController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add expense"),
        content: Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: dropDownValue,
                  //style:
                  //underline:
                  icon: null,
                  items: categNames.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    dropDownValue = newValue!;
                    setStateCallback;
                  },
                ),
                GestureDetector(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onTap: () {
                    // Trigger another dialog for additional features
                    DialogUtils.showAddCategoryDialog(context);
                  },
                )
              ],
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  dateController.text = selectedDate.toLocal().toString();
                }
              },
              decoration: InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Comment'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Update newExp with the entered values
              newExp.amount = double.parse(amountController.text);
              newExp.date = DateTime.parse(dateController.text);
              newExp.comment = commentController.text;

              // Add the new Expense to database:

              expensesProvider.createExpense(newExp);

              // Close the dialog
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  static void showAddIncomeDialog(
      BuildContext context,
      List<Categories> categories,
      IncomesProvider incomesProvider,
      VoidCallback setStateCallback) {
    List<String> categNames = categories
        .where((element) => element.type == CategoryType.income)
        .map((element) => element.name)
        .toList();
    var dropDownValue = categNames.first;
    print(categNames);
    Incomes newInc =
        Incomes(category: categories[0], amount: 0.0, date: DateTime.now());
    TextEditingController amountController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add income"),
        content: Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: dropDownValue,
                  //style:
                  //underline:
                  icon: null,
                  items: categNames.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    dropDownValue = newValue!;
                    setStateCallback;
                  },
                ),
                GestureDetector(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onTap: () {
                    // Trigger another dialog for additional features
                    DialogUtils.showAddCategoryDialog(context);
                  },
                )
              ],
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  dateController.text = selectedDate.toLocal().toString();
                }
              },
              decoration: InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Comment'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Update newInc with the entered values
              newInc.amount = double.parse(amountController.text);
              newInc.date = DateTime.parse(dateController.text);
              newInc.comment = commentController.text;

              // Add the new Expense to database:

              incomesProvider.createIncome(newInc);

              // Close the dialog
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
