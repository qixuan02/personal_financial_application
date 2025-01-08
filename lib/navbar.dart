import 'package:flutter/material.dart';
import 'package:personal_financial_app/Screen/AlertPage.dart';
import 'package:personal_financial_app/Screen/ChartPage.dart';
import 'package:personal_financial_app/Screen/CalculateLoans.dart';
import 'package:personal_financial_app/Screen/Expenses.dart';
import 'package:personal_financial_app/Screen/FinancialPage.dart';
import 'package:personal_financial_app/Screen/Investment.dart';
import 'package:personal_financial_app/Screen/UserSettingsPage.dart';
import 'package:personal_financial_app/Screen/biometric_login.dart';
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
      child: Container(
        color: Color(0xFF1E1E1E),
        child: Column(
          children: [
            Container(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFF292728),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _username[0],
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _username,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Personal Finance',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.settings, color: Colors.white70),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserSettingsPage(
                                      onUsernameChanged: (newUsername) {
                                        setState(() {
                                          _username = newUsername;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildNavItem(
                    icon: Icons.attach_money_rounded,
                    title: 'Expenses',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => Expenses(expenses: [])),
                    ),
                  ),
                  _buildNavItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Financial',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => FinancialPage()),
                    ),
                  ),
                  _buildNavItem(
                    icon: Icons.show_chart_rounded,
                    title: 'Chart',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            ChartPage(currentYear: DateTime.now().year),
                      ),
                    ),
                  ),
                  _buildNavItem(
                    icon: Icons.currency_exchange_rounded,
                    title: 'Investment',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Investment()),
                    ),
                  ),
                  _buildNavItem(
                    icon: Icons.calculate_outlined,
                    title: 'Calculate Price',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => CalculateLoans()),
                    ),
                  ),
                  _buildNavItem(
                    icon: Icons.alarm_rounded,
                    title: 'Alert',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => CategoryAlertSettings()),
                    ),
                  ),
                  Divider(color: Colors.white24, thickness: 1, height: 40),
                  _buildNavItem(
                    icon: Icons.power_settings_new_rounded,
                    title: 'Logout',
                    isLogout: true,
                    onTap: () async {
                      await _clearUserSession();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => BiometricLogin()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.red : Colors.blue,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isLogout ? Colors.red.withOpacity(0.5) : Colors.white30,
          size: 16,
        ),
      ),
    );
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
  }
}
