import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_financial_app/models/financial_model.dart';
import 'package:personal_financial_app/database_helpers/financial_database_helper.dart';
import 'package:personal_financial_app/navbar.dart';

class FinancialPage extends StatefulWidget {
  @override
  _FinancialPageState createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  final FinancialDatabaseHelper _dbHelper = FinancialDatabaseHelper();
  List<FinancialModel> savingsEntries = [];
  List<FinancialModel> incomeEntries = [];
  List<FinancialModel> loanEntries = [];
  double totalSavings = 0;
  double totalIncome = 0;
  double totalLoans = 0;
  final itemController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  DateTime? pickedDate;
  String selectedType = 'savings'; // Default selection

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    savingsEntries = await _dbHelper.getFinancialData('savings');
    totalSavings = savingsEntries.fold(0, (sum, item) => sum + item.amount);

    incomeEntries = await _dbHelper.getFinancialData('income');
    totalIncome = incomeEntries.fold(0, (sum, item) => sum + item.amount);

    loanEntries = await _dbHelper.getFinancialData('loan');
    totalLoans = loanEntries.fold(0, (sum, item) => sum + item.amount);

    setState(() {});
  }

  Future<void> _addFinancialData() async {
    if (itemController.text.isEmpty || amountController.text.isEmpty) return;

    FinancialModel newEntry = FinancialModel(
      name: itemController.text,
      amount: double.parse(amountController.text),
      date: pickedDate ?? DateTime.now(),
      type: selectedType,
    );

    await _dbHelper.insertFinancialData(newEntry);
    _loadFinancialData();
    Navigator.of(context).pop();
  }

  Future<void> _editFinancialData(FinancialModel entry) async {
    // Set the fields for editing
    itemController.text = entry.name;
    amountController.text = entry.amount.toString();
    pickedDate = entry.date;
    selectedType = entry.type;

    // Show the dialog to edit the entry
    _showAddFinancialDialog(isEdit: true, entry: entry);
  }

  // New method to update financial data
  Future<void> _updateFinancialData(FinancialModel entry) async {
    FinancialModel updatedEntry = FinancialModel(
      id: entry.id, // Ensure to pass the ID for the update
      name: itemController.text,
      amount: double.parse(amountController.text),
      date: pickedDate ?? DateTime.now(),
      type: selectedType,
    );

    await _dbHelper.updateFinancialData(
        updatedEntry); // Call the update method in the database helper
    _loadFinancialData(); // Reload data after update
    Navigator.of(context).pop(); // Close the dialog
  }

  Future<void> _deleteFinancialData(int id) async {
    // Show confirmation dialog before deletion
    bool? confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete == true) {
      await _dbHelper.deleteFinancialData(id);
      _loadFinancialData();
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddFinancialDialog({bool isEdit = false, FinancialModel? entry}) {
    itemController.clear();
    amountController.clear();
    pickedDate = null;

    if (isEdit && entry != null) {
      itemController.text = entry.name;
      amountController.text = entry.amount.toString();
      pickedDate = entry.date;
      selectedType = entry.type;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              isEdit ? 'Edit $selectedType Entry' : 'Add $selectedType Entry'),
          content: _buildDialogContent(),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (isEdit && entry != null) {
                  _updateFinancialData(entry); // Call the new update method
                } else {
                  _addFinancialData();
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogContent() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: itemController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(labelText: 'Type'),
            onChanged: (String? newValue) {
              setState(() {
                selectedType = newValue!;
              });
            },
            items: <String>['savings', 'income', 'loan']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        pickedDate = date;
        dateController.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      backgroundColor: Color(0xFF292728),
      appBar: AppBar(
        title: Text('Financial', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF292728),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSummary(),
          Expanded(child: _buildFinancialList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFinancialDialog,
        backgroundColor: Colors.red,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        DateFormat('DD MMMM yyyy').format(DateTime.now()),
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('Savings', totalSavings, Colors.green),
          _buildSummaryItem('Income', totalIncome, Colors.blue),
          _buildSummaryItem('Loans', totalLoans, Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
        Text(
          'RM ${amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }

  Widget _buildFinancialList() {
    return ListView(
      children: [
        _buildSection('Savings', savingsEntries),
        _buildSection('Income', incomeEntries),
        _buildSection('Loans', loanEntries),
      ],
    );
  }

  Widget _buildSection(String title, List<FinancialModel> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        ...entries.map((entry) => Card(
              color: Colors.grey[800],
              child: ListTile(
                title: Text(
                  entry.name,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Amount: RM ${entry.amount.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteFinancialData(entry.id!),
                ),
                onTap: () => _editFinancialData(entry),
              ),
            )),
      ],
    );
  }
}
