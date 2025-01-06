import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsPage extends StatefulWidget {
  final Function(String) onUsernameChanged;

  UserSettingsPage({required this.onUsernameChanged});

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  bool _biometricEnabled = false;
  String _username = 'Z Cheh';

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
  }

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = value;
    });
    await prefs.setBool('biometricEnabled', value);
  }

  void _showEditUsernameDialog() {
    TextEditingController _usernameController =
        TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(hintText: "Enter new username"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  _username = _usernameController.text;
                  widget.onUsernameChanged(_username);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black54,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.grey[800]!],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text('Hi, ' 
            ,style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 10),
            Text(
              _username,
              style: TextStyle(color: Colors.white, fontSize: 18,),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                _showEditUsernameDialog();
              },
            ),
            Divider(color: Colors.white54),
            SwitchListTile(
              title: Text('Enable Biometric Login', style: TextStyle(color: Colors.white),),
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
            ),
            // Add other settings options here
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.amber,
      ),
    );
  }
}
