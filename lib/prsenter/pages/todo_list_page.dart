import 'package:flutter/material.dart';

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