import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_financial_app/navbar.dart';

class Alert {
  final int id;
  final double amount;
  final String frequency;
  final DateTime createdAt;

  Alert({
    required this.id,
    required this.amount,
    required this.frequency,
    required this.createdAt,
  });
}

class SpendingAlertPage extends StatefulWidget {
  const SpendingAlertPage({Key? key}) : super(key: key);

  @override
  State<SpendingAlertPage> createState() => _SpendingAlertPageState();
}

class _SpendingAlertPageState extends State<SpendingAlertPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedFrequency = 'Food';
  List<Alert> alerts = [];
  bool _showSuccess = false;

  final List<String> _frequencies = ['Daily', 'Weekly', 'Food'];

  void _addAlert() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        alerts.add(
          Alert(
            id: DateTime.now().millisecondsSinceEpoch,
            amount: double.parse(_amountController.text),
            frequency: _selectedFrequency,
            createdAt: DateTime.now(),
          ),
        );
        _amountController.clear();
        _showSuccess = true;
      });

      // Hide success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
          });
        }
      });
    }
  }

  void _deleteAlert(int id) {
    setState(() {
      alerts.removeWhere((alert) => alert.id == id);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose(); //try
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text(
          'Spending Alerts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Set New Alert',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: 'RM',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Amount must be greater than 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedFrequency,
                          items: _frequencies
                              .map((freq) => DropdownMenuItem(
                                    value: freq,
                                    child: Text(freq),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFrequency = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _addAlert,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text('Set Alert'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_showSuccess) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Alert set successfully'),
                    ],
                  ),
                ),
              ],
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Active Alerts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...alerts.map((alert) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          'RM${alert.amount.toStringAsFixed(2)} ${alert.frequency}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Set on ${DateFormat('MMM d, yyyy').format(alert.createdAt)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAlert(alert.id),
                        ),
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
