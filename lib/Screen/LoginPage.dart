import 'package:flutter/material.dart';
import 'package:personal_financial_app/Screen/sign_up.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GradientBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MarginWrapper(
                // Wrap only the Column content with margin
                child: Column(
                  children: [
                    _header(context),
                    _inputField(context),
                    button(),
                    sign_upButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        Text(
          "PERSONAL FINANCIAL APP",
          style: TextStyle(fontSize: 22, color: Color(0xff635312)),
        ),
        Text(
          "TAKE CARE OF YOUR FINANCIAL",
          style: TextStyle(fontSize: 12, color: Color(0xff635312)),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: TextField(
            //controller: phoneController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: "Enter Phone Number",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none),
                fillColor: Colors.white.withOpacity(0.2),
                filled: true,
                prefixIcon: Icon(Icons.phone_android),
                prefix: Text('+60')),
          ),
        ),
        SizedBox(height: 10),
        // ElevatedButton(
        //   onPressed: () async {
        //     print('testing sign in button');
        //     await FirebaseAuth.instance.verifyPhoneNumber(
        //         verificationCompleted: (PhoneAuthCredential credential) {},
        //         verificationFailed: (FirebaseAuthException ex) {},
        //         codeSent: (String verificationid, int? resendtoken) {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => OTPScreen(
        //                       verificationid: verificationid,
        //                     )),
        //           );
        //         },
        //         codeAutoRetrievalTimeout: (String verificationId) {},
        //         phoneNumber: phoneController.text.toString());
        //   },
        //   style: ElevatedButton.styleFrom(
        //     shape: const StadiumBorder(),
        //     padding: const EdgeInsets.symmetric(vertical: 16),
        //     backgroundColor: Colors.purple,
        //   ),
        //   child: Text(
        //     "Sign In",
        //     style: TextStyle(fontSize: 20, color: Colors.white),
        //   ),
        // ),
      ],
    );
  }

  Widget button() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          //sendcode();
          print('testing');
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, padding: const EdgeInsets.all(10.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 90),
          child: Text(
            'Send OTP',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget sign_upButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyForm()),
        );
      },
      child: Text(
        'Sign Up',
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white, // Color of the underline
          decorationThickness: 1.0, // This sets the text color to white
        ),
      ),
    );
  }
}

//Background gradient class
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

// Margin wrapper class
class MarginWrapper extends StatelessWidget {
  final Widget child;

  const MarginWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30), // Applying margin to the content
      child: child,
    );
  }
}
