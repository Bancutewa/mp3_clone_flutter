import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/my_dialog.dart';
import '../../utils/my_exception.dart';
import '../../utils/validator.dart';
import '../../widgets/auth/signup_card.dart';
import '../common/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/auth/signup';

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSubmitting = false;

  Future<void> _onSignUp(String name, String email, String password,
      String confirmPassword) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Validate input
      if (!Validator.email(email)) {
        throw MyException('Email không hợp lệ.');
      }
      if (password.length < 6) {
        throw MyException('Mật khẩu phải ít nhất 6 ký tự.');
      }
      if (password != confirmPassword) {
        throw MyException('Mật khẩu xác nhận không khớp.');
      }

      // Create account in Firebase
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      // Save user info to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Navigate to home screen after successful sign-up
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã xảy ra lỗi!';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email đã được sử dụng.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu quá yếu.';
      }
      MyDialog.show(context, 'Lỗi', errorMessage);
    } on MyException catch (e) {
      MyDialog.show(context, 'Lỗi', e.message);
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      MyDialog.show(context, 'Lỗi', 'Đã xảy ra lỗi: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.keyboard_backspace_rounded),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset('assets/images/auth/login_image.png'),
                const SizedBox(height: 20),
                const Text('Đăng ký',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  'Tạo tài khoản mới để sử dụng ứng dụng',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                SignUpCard(_onSignUp),
                if (_isSubmitting) const SizedBox(height: 20),
                if (_isSubmitting) const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
