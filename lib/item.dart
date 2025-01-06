import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_financial_app/models/expense_model.dart';


class Item extends StatelessWidget {
  final ExpenseModel expenseModel;

  
  const Item({
    Key? key,
    required this.expenseModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        padding: EdgeInsets.all(9),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 4.0)],
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 35,
              width: 35,
            ),
            Column(
              children: [
                Text(
                  expenseModel.item,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  DateFormat.yMMMMd().format(expenseModel.date),
                  style: const TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '\RM${expenseModel.amount}',
              style: TextStyle(
                  fontSize: 18,
                  color: expenseModel.isIncome ?Colors.green : Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
