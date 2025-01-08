import 'package:flutter/material.dart';
import 'package:personal_financial_app/Screen/CalculateLoans.dart';
import 'dart:math';
import 'package:personal_financial_app/Screen/monthly_payment.dart';
import 'package:personal_financial_app/Screen/suggest.dart';

class Homeloans extends StatefulWidget {
  const Homeloans({super.key});

  @override
  State<Homeloans> createState() => _HomeloansState();
}

class _HomeloansState extends State<Homeloans> {
  List<bool> isSelected = [false, true];
  double homePrice = 0.0;
  double downPaymentPercentage = 10.0;
  double interestRate = 4.0;
  int loanTenure = 30;
  double marginOfFinance = 90.0;
  double mrtaCost = 0.0;

  final TextEditingController homePriceController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController downPaymentPercentageController =
      TextEditingController();
  final TextEditingController mrtaCostController = TextEditingController();

  void calculateMonthlyPayment() {
    if (homePrice <= 0 || interestRate <= 0 || loanTenure <= 0) {
      return;
    }

    double downPayment = homePrice * (downPaymentPercentage / 100);
    double loanAmount = homePrice - downPayment;

    double monthlyRate = (interestRate / 100) / 12;

    int totalPayments = loanTenure * 12;

    double monthlyPayment = loanAmount *
        (monthlyRate * pow(1 + monthlyRate, totalPayments)) /
        (pow(1 + monthlyRate, totalPayments) - 1);

    double totalPayment = monthlyPayment * totalPayments;
    double totalInterestPaid = totalPayment - loanAmount;

    double mrtaRate = 0.03;
    double mrtaCost = loanAmount * mrtaRate;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyPayment(
          totalLoan: loanAmount,
          annualInterestRate: interestRate,
          loanTenure: loanTenure,
          monthlyPayment: monthlyPayment,
          totalPayment: totalPayment,
          totalInterestPaid: totalInterestPaid,
          mrtaCost: mrtaCost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Calculate Home Loan',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Color(0xFF292728),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: body(),
    );
  }

  Widget body() {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            toggleButtons(),
            SizedBox(height: 20),
            textFieldWithSlider(
              'Home Price',
              homePriceController,
              (value) => setState(() {
                homePrice = double.tryParse(value) ?? 0.0;
              }),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            textFieldWithSlider(
              'Down Payment (%)',
              downPaymentPercentageController,
              (value) => setState(() {
                downPaymentPercentage = double.tryParse(value) ?? 10.0;
              }),
              suffix: '%',
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            textFieldWithSlider(
              'Interest Rate (Annual)',
              interestRateController,
              (value) => setState(() {
                interestRate = double.tryParse(value) ?? 4.0;
              }),
              suffix: '%',
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            lengthOfLoanWidget(),
            SizedBox(height: 20),
            BottomButton(
              buttonText: 'Calculate',
              buttonPressed: calculateMonthlyPayment,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Suggest(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      'Suggestion',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget toggleButtons() {
    return Container(
      height: 100,
      color: Colors.black45,
      child: Center(
        child: ToggleButtons(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: Text('Car Loan', style: TextStyle(color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: Text('Home Loan',
                  style: TextStyle(
                      color: isSelected[1] ? Colors.black : Colors.white)),
            ),
          ],
          isSelected: isSelected,
          onPressed: (index) {
            setState(() {
              for (int i = 0; i < isSelected.length; i++) {
                isSelected[i] = i == index;
              }
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CalculateLoans()),
                );
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Colors.grey[400],
          borderColor: Colors.grey,
        ),
      ),
    );
  }

  Widget lengthOfLoanWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Loan Tenure (Years)', style: TextStyle(color: Colors.white)),
          DropdownButton<int>(
            value: loanTenure,
            dropdownColor: Colors.black,
            style: TextStyle(color: Colors.white),
            items: [10, 15, 20, 25, 30, 35]
                .map((value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value years'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                loanTenure = value ?? 30;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget textFieldWithSlider(
      String label, TextEditingController controller, Function(String) onChange,
      {String suffix = '', TextStyle? style, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white)),
          TextFormField(
            controller: controller,
            onChanged: onChange,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixText: suffix.isEmpty ? 'RM ' : null,
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            style: style,
          ),
        ],
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback buttonPressed;

  const BottomButton({
    Key? key,
    required this.buttonText,
    required this.buttonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: buttonPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.grey[800],
      ),
      child: Text(
        buttonText,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
