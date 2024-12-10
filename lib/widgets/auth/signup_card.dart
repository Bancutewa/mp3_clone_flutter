import 'package:flutter/material.dart';

class SignUpCard extends StatefulWidget {
  final Function(
          String name, String email, String password, String confirmPassword)
      onSubmit;

  const SignUpCard(this.onSubmit, {Key? key}) : super(key: key);

  @override
  State<SignUpCard> createState() => _SignUpCardState();
}

class _SignUpCardState extends State<SignUpCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Họ và tên'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Họ và tên không được để trống.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email không được để trống.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Mật khẩu'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mật khẩu không được để trống.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Xác nhận mật khẩu không được để trống.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  _nameController.text.trim(),
                  _emailController.text.trim(),
                  _passwordController.text,
                  _confirmPasswordController.text,
                );
              }
            },
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );
  }
}
