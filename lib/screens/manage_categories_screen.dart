import 'package:expenso/hives/categories.dart';
import 'package:expenso/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenso/const/constants.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
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
        Consumer<CategoriesProvider>(
          builder: (context, categoriesProvider, child) {
            return FutureBuilder<List<Categories>>(
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
                  List<Categories> categoriesList = snapshot.data ?? [];
                  List<Categories> expenseCategoriesList = categoriesList
                      .where((category) =>
                          category.type == CategoryType.consumption ||
                          category.type == CategoryType.savings)
                      .toList();
                  return ListView.builder(
                    itemCount: expenseCategoriesList.length,
                    itemBuilder: (context, index) {
                      return CategoryTile(
                          category: expenseCategoriesList[index]);
                    },
                  );
                }
              },
            );
          },
        ),
        // Income Categories
        Consumer<CategoriesProvider>(
          builder: (context, categoriesProvider, child) {
            return FutureBuilder<List<Categories>>(
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
                  List<Categories> categoriesList = snapshot.data ?? [];
                  List<Categories> incomeCategoriesList = categoriesList
                      .where((category) => category.type == CategoryType.income)
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
    );
  }
}

class CategoryTile extends StatelessWidget {
  final Categories category;

  const CategoryTile({required this.category, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(category.key.toString()), // Use a unique key for each tile
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
            .deleteCategory(category);
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
