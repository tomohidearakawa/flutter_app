import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreのインポート
import 'package:firebase_auth/firebase_auth.dart';

class ToDoItem {
  String id;
  String title;
  bool completed;

  ToDoItem({required this.id, required this.title, this.completed = false});

  factory ToDoItem.fromDocument(DocumentSnapshot doc) {
    return ToDoItem(
      id: doc.id,
      title: doc['title'],
      completed: doc['completed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
    };
  }
}

class FirestoreService {
  final CollectionReference _todosCollection = FirebaseFirestore.instance.collection('todos');

  Future<void> addTodoItem(String title, String userId) async {
    await _todosCollection.add({'title': title, 'completed': false, 'userId': userId});
  }

  Stream<List<ToDoItem>> getTodoItems(String userId) {
    return _todosCollection
        .where('userId', isEqualTo: userId) // ユーザーIDに基づいてフィルタリング
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => ToDoItem.fromDocument(doc)).toList();
        });
  }

  Future<void> deleteTodoItem(String id) async {
    await _todosCollection.doc(id).delete();
  }

  Future<void> toggleCompleted(ToDoItem item) async {
    await _todosCollection.doc(item.id).update({'completed': !item.completed});
  }
}

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final FirestoreService _firestoreService = FirestoreService();
  TextEditingController todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
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
              if (todoController.text.isNotEmpty) {
                // ログイン中のユーザーIDを取得
                String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                _firestoreService.addTodoItem(todoController.text, userId);
                todoController.clear();
              }
            },
            child: Text('追加'),
          ),
          Expanded(
            child: StreamBuilder<List<ToDoItem>>(
              stream: _firestoreService.getTodoItems(userId), // ユーザーIDを使用してToDoアイテムを取得
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final todos = snapshot.data!;
                  return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final item = todos[index];
                      return ListTile(
                        title: Text(item.title),
                        leading: Checkbox(
                          value: item.completed,
                          onChanged: (bool? value) {
                            _firestoreService.toggleCompleted(item);
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _firestoreService.deleteTodoItem(item.id);
                          },
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('エラーが発生しました！');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
