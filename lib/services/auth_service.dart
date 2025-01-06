// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   createUser(data, context) async {
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: data['phoneNumber'],
//       verificationCompleted: (PhoneAuthCredential credential) {},
//       verificationFailed: (FirebaseAuthException e) {},
//       codeSent: (String verificationId, int? resendToken) {},
//       codeAutoRetrievalTimeout: (String verificationId) {},
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal_financial_app/services/db.dart';

class AuthService {
  var db = Db();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Request OTP
  Future<void> requestOTP(
      String phoneNumber, Function(String) codeSentCallback) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle error
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verification ID for later use
        codeSentCallback(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timeout
      },
    );
  }

  // Verify OTP
  Future<void> verifyOTP(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    // Sign in with the credential
    await _auth.signInWithCredential(credential);
  }
}
