    // void showAddCategoryDialog(BuildContext context) {
    //   showDialog(
    //     context: context,
    //     builder: (_) => AlertDialog(
    //       title: Text("Add Category"),
    //       content: Column(
    //         children: [
    //           // Add widgets for additional features here
    //           // For example:
    //           TextField(
    //             decoration: InputDecoration(labelText: 'lalala 1'),
    //             // Add controller and other properties as needed
    //           ),
    //           // Add more widgets as needed
    //         ],
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             // Add logic to handle additional features
    //             // For example, update your data or perform other actions
    //             Navigator.of(context).pop();
    //           },
    //           child: Text("Apply"),
    //         ),
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //           child: Text("Cancel"),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    // void showAddExpenseDialog(BuildContext context, List<String> categNames,
    //     Expenses newExp, ExpensesProvider expensesProvider) {
    //   var dropDownValue = categNames.first;
    //   showDialog(
    //       context: context,
    //       builder: (_) => AlertDialog(
    //             title: Text("Add expense"),
    //             content: Column(
    //               children: [
    //                 Row(
    //                   children: [
    //                     DropdownButton<String>(
    //                         value: dropDownValue,
    //                         //style:
    //                         //underline:
    //                         icon: null,
    //                         items: categNames.map((value) {
    //                           return DropdownMenuItem(
    //                             value: value,
    //                             child: Text(value),
    //                           );
    //                         }).toList(),
    //                         onChanged: (String? newValue) {
    //                           setState(() {
    //                             dropDownValue = newValue!;
    //                           });
    //                         }),
    //                     GestureDetector(
    //                       child: Icon(
    //                         Icons.add,
    //                         color: Colors.white,
    //                       ),
    //                       onTap: () {
    //                         // Trigger another dialog for additional features
    //                         showAddCategoryDialog(context);
    //                       },
    //                     )
    //                   ],
    //                 ),
    //               ],
    //             ),
    //             actions: [
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.of(context).pop();
    //                 },
    //                 child: Text("Cancel"),
    //               ),
    //             ],
    //           ));
    // }