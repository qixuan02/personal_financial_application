import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_financial_app/Screen/HomeLoans.dart';
import 'package:personal_financial_app/Screen/suggest.dart';
//import 'package:personal_financial_application/houseloan.dart';
//import 'package:personal_financial_application/LoginPage.dart'; // Make sure this import points to the correct file.
import 'package:personal_financial_app/navbar.dart';

class CalculateLoans extends StatefulWidget {
  const CalculateLoans({super.key});

  @override
  _CalculateLoansState createState() =>
      _CalculateLoansState(); // Corrected this part
}

class _CalculateLoansState extends State<CalculateLoans> {
  List<bool> isSelected = [true, false];
  TextEditingController _controller1 = new TextEditingController();
  TextEditingController _controller2 = new TextEditingController();
  TextEditingController _controller3 = new TextEditingController();
  String selected = '';
  double totalInterest = 0;
  double monthlyInterest = 0;
  double monthlyInstallment = 0;

  void loancalculation() {
    final amount = int.parse(_controller1.text) - int.parse(_controller2.text);
    final tinterest =
        amount * (double.parse(_controller3.text) / 100) * int.parse(selected);
    final minterest = tinterest / (int.parse(selected) * 12);
    final minstall = (amount + tinterest) / (int.parse(selected) * 12);
    setState(() {
      totalInterest = tinterest;
      monthlyInterest = minterest;
      monthlyInstallment = minstall;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        drawer: NavBar(),
        appBar: AppBar(
          title: Text(
            'Calculate Price',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          backgroundColor: Color(0xFF292728),
          iconTheme: IconThemeData(
            color: Colors.white, // Set the hamburger icon color to white
          ),
          centerTitle: true,
        ),
        body: body(),
      ),
    );
  }

  Widget body() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(color: Colors.black45),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButtons(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Text(
                              'Car Loan',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected[0]
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Text(
                              'Home Loan',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                        isSelected: isSelected,
                        onPressed: (index) {
                          setState(() {
                            for (int i = 0; i < isSelected.length; i++) {
                              isSelected[i] = (i == index);
                            }
                            if (index == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CalculateLoans()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Homeloans()),
                              );
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: Colors.grey[400],
                        borderColor: Colors.grey,
                      ),
                      // Text(
                      //   'Calculator',
                      //   style: GoogleFonts.robotoMono(fontSize: 35),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 40, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  inputForm(
                      title: 'Car Price',
                      hintText: 'e.g 90000',
                      controller: _controller1),
                  inputForm(
                      title: 'Down Payment',
                      hintText: 'e.g 9000',
                      controller: _controller2),
                  inputForm(
                      title: 'Interest Rate',
                      hintText: 'e.g 3.5',
                      controller: _controller3),
                  Text(
                    'Loan Period',
                    style: GoogleFonts.robotoMono(
                        fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      loanPeriod('1'),
                      loanPeriod('2'),
                      loanPeriod('3'),
                      loanPeriod('4'),
                      loanPeriod('5'),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      loanPeriod('6'),
                      loanPeriod('7'),
                      loanPeriod('8'),
                      loanPeriod('9'),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  GestureDetector(
                    onTap: () {
                      loancalculation();
                      Future.delayed(Duration.zero);
                      showModalBottomSheet(
                          isDismissible: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 400,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 30, 0, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Result',
                                      style:
                                          GoogleFonts.robotoMono(fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    result(
                                        title: 'Total Interest',
                                        amount: totalInterest),
                                    result(
                                        title: 'Monthly Interest',
                                        amount: monthlyInterest),
                                    result(
                                        title: 'Monthly Installment',
                                        amount: monthlyInstallment),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20.0),
                                        child: Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFbc9310),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Recalculate',
                                              style: GoogleFonts.robotoMono(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 74, 74, 74),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                'Calculate',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Suggest(), // Ensure Suggest is imported
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 74, 74, 74),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  'Suggestion',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget result({required String title, required double amount}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 20),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Text(
          'RM' + amount.toStringAsFixed(2),
          style: TextStyle(fontSize: 19),
        ),
      ),
    );
  }

  Widget loanPeriod(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 2, 20, 0),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            border: title == selected
                ? Border.all(color: Color.fromARGB(255, 134, 109, 27), width: 4)
                : null,
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
          ),
          child:
              Center(child: Text(title, style: TextStyle(color: Colors.black))),
        ),
      ),
    );
  }

  Widget inputForm(
      {required String title,
      required TextEditingController controller,
      required String hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(
                  r'^\d*\.?\d*')), // Allows numbers and one decimal point
            ],
            controller: controller,
            decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none),
                hintText: hintText),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
