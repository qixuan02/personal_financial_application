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
import 'package:shared_preferences/shared_preferences.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String _username = 'Z Cheh';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_username),
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
                    MaterialPageRoute(
                      builder: (context) => UserSettingsPage(
                        onUsernameChanged: (newUsername) {
                          setState(() {
                            _username =
                                newUsername; // Update the username in the NavBar
                          });
                        },
                      ),
                    ),
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
                      ChartPage(currentYear: DateTime.now().year)));
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
            onTap: () async {
              // Clear user session data
              await _clearUserSession(); // Implement this method to clear session data

              // Navigate to the LoginPage instead of BiometricLogin
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (BuildContext context) => BiometricLogin()),
              );
            },
          ),
          // others icondata settings_ , moving_, search_, notifications_
        ],
      ),
    );
  }

  // Method to clear user session data
  Future<void> _clearUserSession() async {
    // Clear any stored user data, e.g., using SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken'); // Example key for user token
    // Add any other necessary cleanup here
  }
}
