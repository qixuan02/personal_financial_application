import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import '../Screen/AlertPage.dart';

class AddExpenses extends StatefulWidget {
  final TextEditingController itemController;
  final TextEditingController amountController;
  final TextEditingController dateController;
  final Function(DateTime) onDatePicked;
  final Function(String) onCategoryPicked;

  AddExpenses({
    required this.itemController,
    required this.amountController,
    required this.dateController,
    required this.onDatePicked,
    required this.onCategoryPicked,
  });

  @override
  _AddExpensesState createState() => _AddExpensesState();
}

class _AddExpensesState extends State<AddExpenses> {
  String? _selectedCategory = 'Food';
  final List<String> categories = [
    'Food',
    'Transportation',
    'Health and Wellness',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.itemController,
          decoration: InputDecoration(labelText: 'Item'),
        ),
        TextField(
          controller: widget.amountController,
          decoration: InputDecoration(labelText: 'Amount'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: widget.dateController,
          decoration: InputDecoration(labelText: 'Date'),
          readOnly: true,
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null) {
              setState(() {
                widget.dateController.text = DateFormat.yMMMMd().format(picked);
                widget.onDatePicked(picked);
              });
            }
          },
        ),
        DropdownButton<String>(
          value: _selectedCategory,
          hint: Text('Select Category'),
          items: categories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
              widget.onCategoryPicked(newValue!);
            });
          },
        ),
        // ElevatedButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => AlertPage(categories: categories),
        //       ),
        //     );
        //   },
        //   child: Text('Set Category Limits'),
        // ),
      ],
    );
  }
}
