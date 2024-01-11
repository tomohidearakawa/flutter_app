import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Doリスト',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 名前付きルートの追加
      routes: {
        '/': (context) => ToDoList(),
        '/my_page': (context) => MyPage(), // マイページのルートを追加
      },
      // 初期ルートを設定
      initialRoute: '/',
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
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/my_page'); // マイページに遷移
            },
            child: Text('マイページへ'),
          ),
        ],
      ),
    );
  }
}

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('マイページ'),
      ),
      body: Center(
        child: Text('ここがマイページのコンテンツです。'),
      ),
    );
  }
}
