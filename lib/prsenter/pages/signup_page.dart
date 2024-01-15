import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreのインポート
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザー登録'),
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
          TextField(
            controller: usernameController,
            decoration: InputDecoration(labelText: 'ユーザー名'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text,
                );
                // Firestoreにユーザー名を保存
                await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                  'username': usernameController.text,
                });
                // 登録成功後、トップページに遷移
                Navigator.pushReplacementNamed(context, '/');
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('エラー: ${e.message}')),
                );
              }
            },
            child: Text('登録'),
          ),
        ],
      ),
    );
  }
}