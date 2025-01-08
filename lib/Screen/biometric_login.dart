import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricLogin extends StatefulWidget {
  @override
  _BiometricLoginState createState() => _BiometricLoginState();
}

class _BiometricLoginState extends State<BiometricLogin> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  int _failedAttempts = 0;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });

    if (_biometricEnabled) {
      _checkBiometrics();
    } else {
      _navigateToExpenses();
    }
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });

    if (_canCheckBiometrics) {
      _authenticate();
    } else {
      _navigateToExpenses();
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      });

      if (authenticated) {
        _navigateToExpenses();
      } else {
        _failedAttempts++;
        if (_failedAttempts >= 5) {
          _showPinDialog();
        } else {
          _showRetryDialog();
        }
      }
    } catch (e) {
      print('Error during authentication: $e');
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.toString()}';
      });
      _showRetryDialog();
    }
  }

  void _navigateToExpenses() {
    Navigator.pushReplacementNamed(context, '/expenses');
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Authentication Failed'),
          content: Text('Please try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                _authenticate();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter PIN'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter your PIN'),
            onSubmitted: (value) {
              Navigator.of(context).pop();
              if (value == '1234') {
                _navigateToExpenses();
              } else {
                _showRetryDialog();
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF292728),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.fingerprint,
              size: 100,
              color: _authorized == 'Authorized' ? Colors.green : Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Biometric Authentication',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Authorization status: $_authorized',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      _authorized == 'Authorized' ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
