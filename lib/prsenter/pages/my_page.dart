import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreのインポート
import 'package:firebase_auth/firebase_auth.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String username = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var userDocument = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        username = userDocument.data()?['username'] ?? '名無し';
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$username ページ'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () => Navigator.pushReplacementNamed(context, '/book'),
          ),
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () => Navigator.pushReplacementNamed(context, '/programming'),
          ),
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () => Navigator.pushReplacementNamed(context, '/serach'),
          ),
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () => Navigator.pushReplacementNamed(context, '/other'),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: Text('ようこそ、$username さん'),
      ),
    );
  }
}