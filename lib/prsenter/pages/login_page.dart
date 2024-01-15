import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'メールアドレス'),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'パスワード'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text,
                );
                Navigator.pushReplacementNamed(context, '/'); // ホームページに遷移
              } on FirebaseAuthException catch (e) {
                // エラーメッセージを表示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ログインエラー: ${e.message}')),
                );
              }
            },
            child: Text('ログイン'),
          ),
        ],
      ),
    );
  }
}