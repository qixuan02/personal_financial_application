import 'package:flutter/material.dart';

// class LengthOfLoan extends StatefulWidget {
//   @override
//   _LengthOfLoanState createState() => _LengthOfLoanState();
// }

// class _LengthOfLoanState extends State<LengthOfLoan> {
//   int selectedLoan = 0;
//   @override
//   Widget build(BuildContext context) {
//     var loanYears = [30, 20, 15, 10];
//     return Container(
//       height: 90,
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Length of loan',
//                 style: TextStyle(
//                   color: Colors.grey,
//                 ),
//               ),
//               Text(
//                 'years',
//                 style: TextStyle(
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 5,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: loanYears.map((e) => loanButton(e)).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget loanButton(int numOfYears) {
//     var isSelected = numOfYears == selectedLoan ? true : false;
//     return InkWell(
//       onTap: () {
//         setState(() {
//           selectedLoan = numOfYears;
//         });
//       },
//       child: Container(
//         height: 55,
//         width: 78,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color: isSelected ? Colors.lightBlue : Colors.lightGreen,
//         ),
//         child: Text(
//           numOfYears.toString(),
//           style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: isSelected ? Colors.white : Colors.black),
//         ),
//       ),
//     );
//   }
// }


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
          const Text('Length of Loan (years)', style: TextStyle(color: Colors.grey)),
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

