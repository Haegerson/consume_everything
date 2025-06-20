import 'package:expenso/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/const/constants.dart';
import 'package:expenso/dropdowns.dart';
import 'package:expenso/providers/incomes_provider.dart';
import 'package:expenso/providers/expenses_provider.dart';

import 'package:expenso/models/category.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<DropdownCategoryNamesState> _dropdownExpenseCategoryNamesKey =
      GlobalKey();
  final GlobalKey<DropdownCategoryNamesState> _dropdownIncomesCategoryNamesKey =
      GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(
        builder: (context, categoriesProvider, child) {
      IncomesProvider incomesProvider = Provider.of<IncomesProvider>(context);
      ExpensesProvider expensesProvider =
          Provider.of<ExpensesProvider>(context);
      void showAddCategoryDialog(BuildContext context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController alertThresholdController =
            TextEditingController();
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
                    alertThreshold: alertThreshold,
                  );

                  // Add logic to save the new category to your data store
                  await categoriesProvider.createCategory(newCategory);

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

      return Scaffold(
        appBar: AppBar(
          title: Text('All Categories'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Expense Categories'),
              Tab(text: 'Income Categories'),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
          // Expense Categories
          FutureBuilder<List<Category>>(
            future: categoriesProvider.getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // If the Future is still running, show a loading indicator
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If the Future completed with an error, show an error message
                return Text('Error: ${snapshot.error}');
              } else {
                // If the Future is completed successfully, build the ListView
                List<Category> categoriesList = snapshot.data ?? [];
                List<Category> expenseCategoriesList = categoriesList
                    .where((category) =>
                        category.type == CategoryType.consumption ||
                        category.type == CategoryType.savings)
                    .toList();
                return ListView.builder(
                  itemCount: expenseCategoriesList.length,
                  itemBuilder: (context, index) {
                    return CategoryTile(category: expenseCategoriesList[index]);
                  },
                );
              }
            },
          ),
          // Income Categories
          Consumer<CategoriesProvider>(
            builder: (context, categoriesProvider, child) {
              return FutureBuilder<List<Category>>(
                future: categoriesProvider.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // If the Future is still running, show a loading indicator
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // If the Future completed with an error, show an error message
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // If the Future is completed successfully, build the ListView
                    List<Category> categoriesList = snapshot.data ?? [];
                    List<Category> incomeCategoriesList = categoriesList
                        .where(
                            (category) => category.type == CategoryType.income)
                        .toList();
                    return ListView.builder(
                      itemCount: incomeCategoriesList.length,
                      itemBuilder: (context, index) {
                        return CategoryTile(
                            category: incomeCategoriesList[index]);
                      },
                    );
                  }
                },
              );
            },
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddCategoryDialog(context);
          },
          tooltip: 'Add Category',
          child: Icon(Icons.add),
        ),
      );
    });
  }
}

class CategoryTile extends StatelessWidget {
  final Category category;

  const CategoryTile({required this.category, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(category.id), // Use a unique key for each tile
      background: Container(
        color: Colors.red, // Set the background color when swiping
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Handle the dismissal here:
        Provider.of<CategoriesProvider>(context, listen: false)
            .deleteCategory(category.id!);
      },
      child: ListTile(
        title: Text(category.name),
        subtitle: Text('Monthly Limit: ${category.alertThreshold.toString()}'),
        onTap: () {
          // Handle tile tap if needed, e.g., navigate to a detailed view
        },
      ),
    );
  }
}
