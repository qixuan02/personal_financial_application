import 'package:flutter/material.dart';

class LengthOfLoan extends StatelessWidget {
  final int selectedLoan;
  final ValueChanged<int> onSelected;

  const LengthOfLoan({
    Key? key,
    required this.selectedLoan,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Length of Loan (years)',
              style: TextStyle(color: Colors.grey)),
          DropdownButton<int>(
            value: selectedLoan,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                onSelected(value);
              }
            },
            items: [10, 15, 20, 25, 30]
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text('$e years'),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
