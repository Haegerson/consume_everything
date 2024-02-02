// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_constructors_in_immutables

import 'package:expenso/const/constants.dart';
import 'package:expenso/providers/categories_provider.dart';
import 'package:expenso/old%20trash/history_screen2.dart';
import 'package:expenso/screens/statistics_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:expenso/hives/incomes.dart';
import 'package:expenso/hives/expenses.dart';
import 'package:expenso/hives/categories.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:expenso/screens/history_screen.dart';
import 'package:expenso/screens/manage_categories_screen.dart';
import 'package:expenso/dropdowns.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ExpensesAdapter());
  Hive.registerAdapter(IncomesAdapter());
  Hive.registerAdapter(CategoriesAdapter());

  // Initialize locale data for date formatting
  await initializeDateFormatting('en_US');

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ExpensesProvider>(create: (_) => ExpensesProvider()),
    ChangeNotifierProvider<IncomesProvider>(create: (_) => IncomesProvider()),
    ChangeNotifierProvider<CategoriesProvider>(
        create: (_) => CategoriesProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenso',
      theme: ThemeData.dark().copyWith(),
      localizationsDelegates: [
        // Add the MonthYearPickerLocalizations delegate
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // Add other locales as needed
      ],
      home: OverviewScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class OverviewScreen extends StatefulWidget {
  OverviewScreen({super.key, required this.title});

  final String title;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final GlobalKey<DropdownCategoryNamesState> _dropdownExpenseCategoryNamesKey =
      GlobalKey();
  final GlobalKey<DropdownCategoryNamesState> _dropdownIncomesCategoryNamesKey =
      GlobalKey();
  @override
  Widget build(BuildContext context) {
    CategoriesProvider categProvider = Provider.of<CategoriesProvider>(context);
    ExpensesProvider expensesProvider = Provider.of<ExpensesProvider>(context);
    IncomesProvider incomesProvider = Provider.of<IncomesProvider>(context);

    void showAddCategoryDialog(BuildContext context) {
      TextEditingController nameController = TextEditingController();
      TextEditingController alertThresholdController = TextEditingController();
      String selectedType = CategoryType.consumption;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Add Category"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown for category type
              Text("Category Type"),
              DropdownCategoryTypes(
                onTypeSelected: (String type) {
                  setState(() {
                    selectedType = type; // Update the selected category
                  });
                },
              ),
              SizedBox(height: 16.0), // Add some spacing

              // Text field for category name
              Text("Category Name"),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Enter category name'),
              ),
              Text("Threshold for alert"),
              TextField(
                controller: alertThresholdController,
                decoration: InputDecoration(labelText: 'Enter threshold'),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String categoryName = // Get the entered category name
                    (nameController.text.isEmpty)
                        ? "Untitled"
                        : nameController.text;
                final double? alertThreshold =
                    double.parse(alertThresholdController.text);

                Categories newCategory = Categories(
                    name: categoryName,
                    type: selectedType,
                    alertThreshold: alertThreshold);

                // Add logic to save the new category to your data store
                await categProvider.createCategory(newCategory);
                categProvider.printCategories();

                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  // Trigger an update in the DropdownCategoryNames widget
                  _dropdownExpenseCategoryNamesKey.currentState
                      ?.updateCategories();
                  _dropdownIncomesCategoryNamesKey.currentState
                      ?.updateCategories();
                });
              },
              child: Text("Apply"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        ),
      );
    }

    void showAddExpenseDialog(BuildContext context) async {
      List<Categories> categories = await categProvider.getCategories();
      Categories selectedCategory = categories[0];
      String selectedCategoryName = selectedCategory.name;

      Expenses newExp =
          Expenses(category: categories[0], amount: 0.0, date: DateTime.now());
      TextEditingController amountController = TextEditingController();
      TextEditingController dateController = TextEditingController();
      TextEditingController commentController = TextEditingController();
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Add expense"),
          content: Column(
            children: [
              Row(
                children: [
                  DropdownCategoryNames(
                    key: _dropdownExpenseCategoryNamesKey,
                    onCategorySelected: (String category) {
                      setState(() {
                        selectedCategoryName =
                            category; // Update the selected category
                      });
                    },
                    isExpense: true,
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onTap: () {
                      // Trigger another dialog for adding categories
                      showAddCategoryDialog(context);
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
                selectedCategory =
                    categProvider.getCategoryByName(selectedCategoryName);
                newExp.category = selectedCategory;
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

    void showAddIncomeDialog(BuildContext context) async {
      List<Categories> categories = await categProvider.getCategories();
      Categories selectedCategory = categories[0];
      String selectedCategoryName = selectedCategory.name;

      Incomes newInc =
          Incomes(category: categories[0], amount: 0.0, date: DateTime.now());
      TextEditingController amountController = TextEditingController();
      TextEditingController dateController = TextEditingController();
      TextEditingController commentController = TextEditingController();
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Add Income"),
          content: Column(
            children: [
              Row(
                children: [
                  DropdownCategoryNames(
                    key: _dropdownIncomesCategoryNamesKey,
                    onCategorySelected: (String category) {
                      setState(() {
                        selectedCategoryName =
                            category; // Update the selected category
                      });
                    },
                    isExpense: false,
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onTap: () {
                      // Trigger another dialog for adding categories
                      showAddCategoryDialog(context);
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
                selectedCategory =
                    categProvider.getCategoryByName(selectedCategoryName);
                newInc.category = selectedCategory;
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

    Categories cat = Categories(
        name: "test", type: CategoryType.consumption, alertThreshold: null);
    // List<Categories> categories = [];
    Expenses exp = Expenses(
      category: cat,
      amount: 10.0,
      comment: 'Sample comment',
      date: DateTime.now(),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to another screen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManageCategoriesScreen()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white), // Outline color
                      borderRadius: BorderRadius.circular(
                          10), // Optional: for rounded corners
                    ),
                    child: Center(
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to another screen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StatisticsOverviewScreen()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white), // Outline color
                      borderRadius: BorderRadius.circular(
                          10), // Optional: for rounded corners
                    ),
                    child: Center(
                      child: Text(
                        'Statistics',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to another screen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white), // Outline color
                      borderRadius: BorderRadius.circular(
                          10), // Optional: for rounded corners
                    ),
                    child: Center(
                      child: Text(
                        'History',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "addExpense",
            onPressed: () {
              showAddExpenseDialog(context);
            },
            tooltip: 'Add Expense',
            child: const Text("Exp"),
          ),
          FloatingActionButton(
            heroTag: "addIncome",
            onPressed: () {
              showAddIncomeDialog(context);
            },
            tooltip: 'Add Income',
            child: const Text("Inc"),
          ),
        ],
      ),
    );
  }
}
