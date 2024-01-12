import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// ナビゲーションバーを持つベースページ
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



class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<String> todos = [];
  TextEditingController todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Doリスト'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: todoController,
            decoration: InputDecoration(
              hintText: '新しいタスクを追加',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                String newTodo = todoController.text;
                if (newTodo.isNotEmpty) {
                  todos.add(newTodo);
                  todoController.clear();
                }
              });
            },
            child: Text('追加'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(todos[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        todos.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ログインページ
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
              // ログイン処理
              try {
                UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text,
                );
                Navigator.pushReplacementNamed(context, '/'); // ホームページに遷移
              } on FirebaseAuthException catch (e) {
                // エラー処理
                print(e.message);
              }
            },
            child: Text('ログイン'),
          ),
        ],
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('マイページ'),
      ),
      body: Center(
        child: Text('ようこそ、$username さん'),
      ),
    );
  }
}
