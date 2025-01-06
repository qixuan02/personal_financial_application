import 'package:flutter/material.dart';
import 'package:personal_financial_app/Screen/AlertPage.dart';
import 'package:personal_financial_app/Screen/ChartPage.dart';
// import 'package:personal_financial_application/Alert.dart';
import 'package:personal_financial_app/Screen/CalculateLoans.dart';
// import 'package:personal_financial_application/Chart.dart';
import 'package:personal_financial_app/Screen/Expenses.dart';
import 'package:personal_financial_app/Screen/FinancialPage.dart';
import 'package:personal_financial_app/Screen/Investment.dart';
// import 'package:personal_financial_app/Screen/LoginPage.dart';
import 'package:personal_financial_app/Screen/UserSettingsPage.dart';
import 'package:personal_financial_app/Screen/biometric_login.dart';
// import 'package:personal_financial_application/Savings.dart';
// import 'package:personal_financial_application/LoginPage.dart';
//import 'package:personal_financial_application/models/stock.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Z Cheh'),
            accountEmail: Text(''),
            // currentAccountPicture: CircleAvatar(
            //   child: ClipOval(child: Image.asset('')),
            // ),
            decoration: BoxDecoration(
              color: Color(0xFF292728),
            ),
            otherAccountsPictures: [
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserSettingsPage()),
                  );
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.attach_money_rounded),
            title: Text('Expenses'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => Expenses(expenses: [])));
            },
          ),
          ListTile(
            leading: Icon(Icons.credit_card_outlined),
            title: Text('Financial'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => FinancialPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.show_chart_rounded),
            title: Text('Chart'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ChartPage(year: DateTime.now().year)));
            },
          ),
          ListTile(
            leading: Icon(Icons.currency_exchange_rounded),
            title: Text('Investment'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => Investment()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: Text('Calculate Price'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => CalculateLoans()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.alarm_rounded),
            title: const Text('Alert'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => SpendingAlertPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new_rounded),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => BiometricLogin()));
            },
          ),
          // others icondata settings_ , moving_, search_, notifications_
        ],
      ),
    );
  }
}
