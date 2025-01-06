import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_financial_app/Screen/Expenses.dart';
//import 'package:get/get.dart';
import 'package:personal_financial_app/models/appvalidator.dart';
import 'package:personal_financial_app/services/auth_service.dart';

class MyForm extends StatefulWidget {
  MyForm({super.key});

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _phoneNumberController = TextEditingController();
  final _otpController = TextEditingController();

  var authService = AuthService();
  var isLoader = false;
  String? verificationId;

  // Future<void> _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       isLoader = true;
  //     });
  //     var data = {
  //       'phoneNumber': _phoneNumberController.text,
  //     };
  //     await authService.createUser(data, context);
  //     setState(() {
  //       isLoader = false;
  //     });
  //     // ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
  //     //     const SnackBar(content: Text('Request OTP successfully')));
  //   }
  // }
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      try {
        await authService.requestOTP(
          _phoneNumberController.text,
          (String verId) {
            setState(() {
              verificationId = verId;
              isLoader = false;
            });
            // Show OTP input field to the user
            print('Verification ID received: $verificationId');
          },
        );
      } catch (e) {
        setState(() {
          isLoader = false;
        });
        print('Error requesting OTP: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to request OTP. Please try again.')),
        );
        // Handle error (e.g., show a message to the user)
      }
    }
  }

  // Future<void> _verifyOTP() async {
  //   if (verificationId != null) {
  //     setState(() {
  //       isLoader = true;
  //     });
  //     try {
  //       String smsCode = _otpController.text;

  //       print('Entered OTP: $smsCode');
  //       print('Verification ID: $verificationId');

  //       await authService.verifyOTP(verificationId!, smsCode);
  //       setState(() {
  //         isLoader = false;
  //       });
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => Expenses(
  //                   title: 'Expenses',
  //                 )),
  //       );
  //     } catch (e) {
  //       setState(() {
  //         isLoader = false;
  //       });
  //       // Handle verification failure
  //       print('Verification failed: $e');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Verification failed. Please try again.')),
  //       );
  //     }
  //     // Handle successful verification
  //   }
  // }

  // ... existing code ...

  Future<void> _verifyOTP() async {
    if (verificationId == null) {
      print('Verification ID is null. Cannot verify OTP.');
      return;
    }

    setState(() {
      isLoader = true;
    });

    try {
      String smsCode = _otpController.text;

      print('Entered OTP: $smsCode');
      print('Verification ID: $verificationId');

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        isLoader = false;
      });
      print('OTP verified successfully. Redirecting to expenses page.');
      navigateToExpensesPage(context);
    } catch (e) {
      setState(() {
        isLoader = false;
      });
      print('Verification failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed. Please try again.')),
      );
    }
  }

  void navigateToExpensesPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Expenses(expenses: []),
      ),
    );
  }

// ... existing code ...

  var appValidator = AppValidator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: Text(
                    'Personal Financial Application',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 19),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: Colors.black),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration('Phone Number', Icons.call),
                  validator: appValidator.validatePhoneNumber,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoader ? null : _submitForm,
                  child: isLoader
                      ? CircularProgressIndicator()
                      : Text('Request OTP'),
                ),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration('Enter OTP', Icons.lock),
                ),

                SizedBox(
                  height: 40,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoader ? null : _verifyOTP,
                    child: isLoader
                        ? CircularProgressIndicator()
                        : Text('Verify OTP'),
                  ),
                ),
                SizedBox(
                    height:
                        20), // Add some space between the button and the text button
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context); // Assuming the login page is the previous page
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white, // Color of the underline
                      decorationThickness: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
        fillColor: Colors.white54,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        filled: true,
        labelStyle: TextStyle(color: Colors.blueGrey),
        labelText: label,
        suffixIcon: Icon(
          suffixIcon,
          color: Colors.blueGrey,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)));
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF292728),
            Color(0xFF656565),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
