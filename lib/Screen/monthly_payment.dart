import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyPayment extends StatelessWidget {
  final double totalLoan;
  final double annualInterestRate;
  final int loanTenure;
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterestPaid;
  final double mrtaCost;

  const MonthlyPayment({
    super.key,
    required this.totalLoan,
    required this.annualInterestRate,
    required this.loanTenure,
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterestPaid,
    required this.mrtaCost,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_MY',
      symbol: 'RM ',
    );

    return Scaffold(
      backgroundColor: Color(0xFF292728),
      appBar: AppBar(
        title: Text(
          'Loan Summary',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Color(0xFF292728),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            detailRow('Total Loan:', 'RM${formatter.format(totalLoan)}'),
            detailRow('Annual Interest Rate:',
                '${annualInterestRate.toStringAsFixed(2)}%'),
            detailRow('Loan Tenure:', '$loanTenure years'),
            Divider(color: Colors.grey, height: 40),
            Text(
              'Payment Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            detailRow(
                'Monthly Payment:', 'RM${formatter.format(monthlyPayment)}'),
            detailRow('Total Payment:', 'RM${formatter.format(totalPayment)}'),
            detailRow('Total Interest Paid:',
                'RM${formatter.format(totalInterestPaid)}'),
            detailRow('MRTA Cost:', 'RM${formatter.format(mrtaCost)}'),
            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
