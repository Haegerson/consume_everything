// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:expenso/dialog_utils.dart';
import 'package:expenso/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:expenso/hives/incomes.dart';
import 'package:expenso/hives/expenses.dart';
import 'package:expenso/hives/categories.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:expenso/providers/category_data.dart';
import 'package:expenso/enumerators.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpensesAdapter());
  Hive.registerAdapter(IncomesAdapter());
  Hive.registerAdapter(CategoriesAdapter());

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
  @override
  Widget build(BuildContext context) {
    CategoriesProvider categProvider = Provider.of<CategoriesProvider>(context);
    ExpensesProvider expensesProvider = Provider.of<ExpensesProvider>(context);

    Categories cat = Categories(name: "test", type: "consume");
    List<Categories> categories = [];
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
                child: Container(
                  margin: EdgeInsets.all(5),
                  color: Colors.red,
                ),
                onTap: () async {
                  categories = await categProvider.getCategories();
                  await categProvider.createCategory(cat);
                  await expensesProvider.createExpense(exp);
                  setState(() {});
                  print("categories are");
                  print(categories);
                },
              )),
              Expanded(
                  child: GestureDetector(
                child: Container(
                  margin: EdgeInsets.all(5),
                  color: Colors.lightGreen, // DELETE CATEGORIES
                ),
                onTap: () async {
                  categories = await categProvider.getCategories();
                  await categProvider.deleteAllCategories();
                  setState(() {});
                  print("categories are:");
                  print(categories);
                },
              )),
              Expanded(
                  child: GestureDetector(
                      child: Container(
                margin: EdgeInsets.all(5),
                color: Colors.red,
              ))),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              categories = await categProvider.getCategories();

              DialogUtils.showAddExpenseDialog(
                  context, categories, expensesProvider, () {
                setState(() {});
              });
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () async {
              // Hier Income Dialog
            },
            tooltip: 'Decrease',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}