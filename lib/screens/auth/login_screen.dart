import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/admin_screen.dart';
import '../../utils/config.dart';
import '../../models/account.dart';
import '../../models/playlist.dart';
import '../../utils/my_dialog.dart';
import '../../utils/my_exception.dart';
import '../../utils/validator.dart';
import '../../widgets/auth/login_card.dart';
import '../common/home_screen.dart';
import './forgot_screen.dart';
import './signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/auth/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSubmitting = false;

  Future<bool> _onSubmit(String email, String password) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Kiểm tra email có hợp lệ hay không
      if (!Validator.email(email)) {
        throw MyException('Email không hợp lệ.');
      }

      // Kiểm tra độ dài của mật khẩu
      if (password.length < 6) {
        throw MyException('Mật khẩu phải ít nhất 6 ký tự.');
      }

      // Thực hiện đăng nhập Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin người dùng đã đăng nhập
      final user = userCredential.user;
      if (user == null) {
        throw MyException('Không thể lấy thông tin người dùng.');
      }

      final firestore = FirebaseFirestore.instance;

      // Lấy thông tin tài khoản từ Firestore
      final documentSnapshot =
          await firestore.collection('users').doc(user.uid).get();
      final map = documentSnapshot.data();
      if (map == null) {
        throw MyException('Không tìm thấy thông tin tài khoản.');
      }

      // Lấy danh sách playlist của người dùng
      final querySnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('user_playlists')
          .get();

      List<Playlist> userPlaylists = querySnapshot.docs
          .map((query) => Playlist.fromMapFirebase(query.data(), query.id))
          .toList();

      // Lưu thông tin người dùng vào Config
      Config.instance.myAccount = Account(
        uid: user.uid,
        name: map['name'] ?? 'Người dùng',
        email: email,
        userPlaylists: userPlaylists,
      );

      await Config.instance.saveAccountInfo();
      await Config.instance.saveAccountPlaylists();

      // Điều hướng sang màn hình chính
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      return true;
    } on MyException catch (error) {
      MyDialog.show(context, 'Lỗi', error.toString());
    } on FirebaseAuthException catch (error) {
      // Xử lý các lỗi từ FirebaseAuth
      print('FirebaseAuthException: $error');
      String errorMessage = 'Lỗi không xác định.\n(Firebase Auth)';
      if (error.code == 'user-not-found') {
        errorMessage = 'Tài khoản không tồn tại.';
      } else if (error.code == 'wrong-password') {
        errorMessage = 'Sai mật khẩu.';
      } else if (error.code == 'network-request-failed') {
        errorMessage = 'Kết nối mạng không khả dụng. Vui lòng kiểm tra lại.';
      }
      MyDialog.show(context, 'Lỗi', errorMessage);
    } on FirebaseException catch (error) {
      // Xử lý các lỗi từ Firebase Firestore
      print('FirebaseException: $error');
      const errorMessage =
          'Lỗi khi kết nối cơ sở dữ liệu. Vui lòng thử lại sau.';
      MyDialog.show(context, 'Lỗi', errorMessage);
    } catch (error, stackTrace) {
      // Ghi log lỗi không xác định
      print('Exception: $error');
      print('Stack Trace: $stackTrace');
      const errorMessage = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
      MyDialog.show(context, 'Lỗi', errorMessage);
    } finally {
      // Luôn tắt trạng thái loading
      setState(() {
        _isSubmitting = false;
      });
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.keyboard_backspace_rounded),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ForgotScreen.routeName);
                },
                child: const Text(
                  'Quên mật khẩu',
                  style: TextStyle(color: Colors.black),
                )),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/auth/login_image.png'),
              const SizedBox(height: 10),
              const Text('Đăng nhập',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'Vui lòng điền thông tin đăng nhập bên dưới để tiếp tục',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              LoginCard(_onSubmit),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản?'),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(SignUpScreen.routeName);
                      },
                      child: const Text('Đăng ký'))
                ],
              ),
              const Spacer(),
              if (_isSubmitting) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
