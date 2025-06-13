// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_constructors_in_immutables, prefer_const_literals_to_create_immutables

import 'package:expenso/const/constants.dart';
import 'package:expenso/providers/categories_provider.dart';
import 'package:expenso/screens/statistics_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/providers/expenses_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:expenso/screens/history_screen.dart';
import 'package:expenso/screens/manage_categories_screen.dart';
import 'package:expenso/dropdowns.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expenso/models/category.dart';
import 'package:expenso/models/expense.dart';
import 'package:expenso/models/income.dart';
import 'services/api_client.dart';
import 'package:expenso/services/category_api.dart';
import 'package:expenso/services/expense_api.dart';
import 'package:expenso/services/income_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient =
      ApiClient(baseUrl: 'https://<your-xano-slug>.xano.io/api:1/');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoriesProvider(CategoryApi(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpensesProvider(ExpenseApi(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => IncomesProvider(IncomeApi(apiClient)),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
  ValueNotifier<int> _updateNotifier = ValueNotifier<int>(0);

  void refreshData() {
    final expensesProvider = context.read<ExpensesProvider>();
    final incomesProvider = context.read<IncomesProvider>();
    final categProvider = context.read<CategoriesProvider>();

    setState(() {
      _updateNotifier
          .value++; // Increment the ValueNotifier to trigger a rebuild
      _currentConsumeExpenses = expensesProvider.getCurrentExpenses(
        CategoryType.consumption,
        categoriesProvider: categProvider,
      );
      _currentSavingsExpenses = expensesProvider.getCurrentExpenses(
        CategoryType.savings,
        categoriesProvider: categProvider,
      );
      _currentIncomes = incomesProvider.getCurrentIncomes();
    });
  }

  final GlobalKey<DropdownCategoryNamesState> _dropdownExpenseCategoryNamesKey =
      GlobalKey();
  final GlobalKey<DropdownCategoryNamesState> _dropdownIncomesCategoryNamesKey =
      GlobalKey();
  late Future<double> _currentConsumeExpenses;
  late Future<double> _currentSavingsExpenses;
  late Future<double> _currentIncomes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expensesProvider = context.read<ExpensesProvider>();
      final incomesProvider = context.read<IncomesProvider>();
      final categProvider = context.read<CategoriesProvider>();

      setState(() {
        _currentConsumeExpenses = expensesProvider.getCurrentExpenses(
          CategoryType.consumption,
          categoriesProvider: categProvider,
        );
        _currentSavingsExpenses = expensesProvider.getCurrentExpenses(
          CategoryType.savings,
          categoriesProvider: categProvider,
        );
        _currentIncomes = incomesProvider.getCurrentIncomes();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final categProvider = context.read<CategoriesProvider>();
    final expensesProvider = context.read<ExpensesProvider>();
    final incomesProvider = context.read<IncomesProvider>();

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
                double? alertThreshold;
                if (alertThresholdController.text.isNotEmpty) {
                  try {
                    alertThreshold =
                        double.parse(alertThresholdController.text);
                  } catch (e) {
                    // Handle the case where the input is not a valid double
                    print("Invalid double input for threshold");
                    alertThreshold = null;
                  }
                }
                Category newCategory = Category(
                    name: categoryName,
                    type: selectedType,
                    alertThreshold: alertThreshold);

                // Add logic to save the new category to your data store
                await categProvider.createCategory(newCategory);

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
      List<Category> categories = await categProvider.getCategories();
      Category selectedCategory = categories[0];
      String selectedCategoryName = selectedCategory.name;

      Expense newExp = Expense(
        id: null,
        categoryId: categories[0].id!,
        amount: 0.0,
        date: DateTime.now(),
      );
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
                newExp = Expense(
                  id: null,
                  categoryId: selectedCategory.id!,
                  amount: double.parse(amountController.text),
                  date: DateTime.parse(dateController.text),
                  comment: commentController.text,
                );

                // Add the new Expense to database:

                expensesProvider.createExpense(newExp);
                _currentConsumeExpenses = expensesProvider.getCurrentExpenses(
                  CategoryType.consumption,
                  categoriesProvider: categProvider,
                );

                // Close the dialog
                Navigator.of(context).pop();
                _updateNotifier
                    .value++; // Increment the ValueNotifier to trigger a rebuild
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
      List<Category> categories = await categProvider.getCategories();
      Category selectedCategory = categories[0];
      String selectedCategoryName = selectedCategory.name;
      Income newInc = Income(
        id: null,
        categoryId: categories[0].id!,
        amount: 0.0,
        date: DateTime.now(),
      );

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
              onPressed: () async {
                final selectedCategory =
                    categProvider.getCategoryByName(selectedCategoryName);

                // Recreate newInc with the proper fields
                final newInc = Income(
                  id: null, // let Xano assign the real ID
                  categoryId: selectedCategory.id!,
                  amount: double.parse(amountController.text),
                  comment: commentController.text,
                  date: DateTime.parse(dateController.text),
                );

                // Send it to Xano
                await incomesProvider.createIncome(newInc);

                // Refresh your future
                _currentIncomes = incomesProvider.getCurrentIncomes();

                // Close dialog and trigger rebuild
                Navigator.of(context).pop();
                _updateNotifier.value++;
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

    return ValueListenableBuilder(
        valueListenable: _updateNotifier,
        builder: (context, _, __) {
          return FutureBuilder(
              future: Future.wait([
                _currentConsumeExpenses,
                _currentSavingsExpenses,
                _currentIncomes,
                expensesProvider.getCategoriesOverThreshold(
                    categoriesProvider: categProvider),
              ]), // Use Future.wait to wait for all futures
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While the Future is still loading
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // If an error occurred
                  return Text('Error: ${snapshot.error}');
                } else {
                  double currentConsumeExpenses =
                      (snapshot.data as List<dynamic>)[0] as double;
                  double currentSavingsExpenses =
                      (snapshot.data as List<dynamic>)[1] as double;
                  double currentIncomes =
                      (snapshot.data as List<dynamic>)[2] as double;
                  Map<String, double> categoriesOverThreshold = (snapshot.data
                      as List<dynamic>)[3] as Map<String, double>;
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(""),
                    ),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      DateFormat('MMMM, yyyy')
                                          .format(DateTime.now()),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Consume: ${currentConsumeExpenses.toString()}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  Text(
                                    "Savings: ${currentSavingsExpenses.toString()}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  Text(
                                    "Incomes: ${currentIncomes.toString()}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text(
                                  'Alerts',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                children: [
                                  ListView(
                                    shrinkWrap: true,
                                    children: categoriesOverThreshold.keys
                                        .map((categoryName) {
                                      return ListTile(
                                        title: Text(
                                          categoryName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[850], // Dark grey color
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    20.0), // Rounded top-left corner
                                topRight: Radius.circular(
                                    20.0), // Rounded top-right corner
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    NavigationPanel(
                                      panelText: "Categories",
                                      targetScreen: ManageCategoriesScreen(),
                                      icon: null,
                                      flex: 1,
                                    ),
                                    NavigationPanel(
                                      panelText: "Statistics",
                                      targetScreen: StatisticsOverviewScreen(),
                                      icon: null,
                                      flex: 1,
                                    ),
                                    NavigationPanel(
                                      panelText: "History",
                                      targetScreen: HistoryScreen(
                                          refreshCallback: refreshData),
                                      icon: null,
                                      flex: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    floatingActionButton: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          heroTag: "addExpense",
                          onPressed: () {
                            showAddExpenseDialog(context);
                            setState(() {
                              // Update the state variables
                              _currentConsumeExpenses =
                                  expensesProvider.getCurrentExpenses(
                                CategoryType.consumption,
                                categoriesProvider: categProvider,
                              );
                              _currentSavingsExpenses =
                                  expensesProvider.getCurrentExpenses(
                                CategoryType.savings,
                                categoriesProvider: categProvider,
                              );
                            });
                          },
                          tooltip: 'Add Expense',
                          child: const Text("Exp"),
                        ),
                        SizedBox(
                            width:
                                10), // Add some space between FloatingActionButton
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
              });
        });
  }
}
