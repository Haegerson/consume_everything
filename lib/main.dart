// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:expenso/hives/incomes.dart';
import 'package:expenso/hives/expenses.dart';
import 'package:expenso/providers/expense_provider.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:expenso/providers/category_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpensesAdapter());
  Hive.registerAdapter(IncomesAdapter());

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ExpensesProvider>(create: (_) => ExpensesProvider()),
    ChangeNotifierProvider<IncomesProvider>(create: (_) => IncomesProvider()),
    ChangeNotifierProvider<CategoryData>(create: (_) => CategoryData()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenso',
      theme: ThemeData.dark().copyWith(),
      home: const OverviewScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key, required this.title});

  final String title;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    CategoryData categProvider = Provider.of<CategoryData>(context);
    List categories = categProvider.expenseCategories;
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
              ))),
              Expanded(
                  child: GestureDetector(
                      child: Container(
                margin: EdgeInsets.all(5),
                color: Colors.red,
              ))),
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
            onPressed: () {
              String dropDownValue = categories[0];
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
                                    items:
                                        categProvider.getExpenseDropdownList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropDownValue = newValue!;
                                      });
                                    }),
                                GestureDetector(
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    categProvider.addExpenseCategory("Test");
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                        ],
                      ));
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () async {
              // Hier Income Dialog
            },
            tooltip: 'Increment',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
