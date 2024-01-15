import 'package:flutter/material.dart';
import 'prsenter/pages/todo_list_page.dart';
import 'prsenter/pages/login_page.dart';
import 'prsenter/pages/my_page.dart';
import 'prsenter/pages/signup_page.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  BasePage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アプリのタイトル'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => Navigator.pushReplacementNamed(context, '/my_page'),
          ),
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          IconButton(
            icon: Icon(Icons.app_registration),
            onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
          ),
        ],
      ),
      body: child,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Doリスト',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => BasePage(child: ToDoList()),
        '/my_page': (context) => BasePage(child: MyPage()),
        '/login': (context) => BasePage(child: LoginPage()),
        '/signup': (context) => BasePage(child: SignUpPage()),
      },
      initialRoute: '/signup',
    );
  }
}