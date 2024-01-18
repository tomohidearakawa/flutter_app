import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreのインポート
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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

  factory ToDoItem.fromMap(Map<String, dynamic> map) {
    return ToDoItem(
      id: map['id'],
      title: map['title'],
      completed: map['completed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
    };
}

}

class GoalItem {
  String id;
  String title;
  List<String> categories;
  List<ToDoItem> todos;
  DateTime? dueDate;
  String? comment;

  GoalItem({
    required this.id,
    required this.title,
    this.categories = const [],
    this.todos = const [],
    this.dueDate,
    this.comment,
  });

  factory GoalItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // ドキュメントデータを取得

    return GoalItem(
      id: doc.id,
      title: data?['title'] ?? '', // データが存在しない場合のデフォルト値を設定
      categories: List<String>.from(data?['categories'] ?? []),
      todos: (data?['todos'] as List? ?? []).map((todo) => ToDoItem.fromMap(todo)).toList(),
      dueDate: data?['dueDate']?.toDate() ?? null,
      comment: data?['comment'] ?? null,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'categories': categories,
      'todos': todos.map((todo) => todo.toMap()).toList(),
      'dueDate': dueDate,
      'comment': comment,
    };
  }
}



class Categories {
  static const List<String> predefinedCategories = [
    '仕事', '勉強', '健康', '趣味', 'その他'
  ];
}


class FirestoreService {
  final CollectionReference _todosCollection = FirebaseFirestore.instance.collection('todos');
  final CollectionReference _goalsCollection = FirebaseFirestore.instance.collection('goals');

  // ToDo アイテムを追加
  Future<void> addTodoItem(String title, String userId) async {
    await _todosCollection.add({'title': title, 'completed': false, 'userId': userId});
  }

  // 特定のユーザーの ToDo アイテムを取得
  Stream<List<ToDoItem>> getTodoItems(String userId) {
    return _todosCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ToDoItem.fromDocument(doc)).toList());
  }

  // ToDo アイテムを削除
  Future<void> deleteTodoItem(String id) async {
    await _todosCollection.doc(id).delete();
  }

  // ToDo アイテムの完了状態をトグル
  Future<void> toggleCompleted(ToDoItem item) async {
    await _todosCollection.doc(item.id).update({'completed': !item.completed});
  }

  // 目標を追加
  Future<void> addGoalItem(String title, List<String> categories, DateTime dueDate, String comment, String userId) async {
    await _goalsCollection.add({
      'title': title,
      'categories': categories,
      'dueDate': dueDate,
      'comment': comment,
      'userId': userId,
      'todos': [], // 空の ToDo アイテムリストを追加
    });
  }


  // 特定のユーザーの目標を取得
  Stream<List<GoalItem>> getGoalItems(String userId) {
    return _goalsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GoalItem.fromDocument(doc)).toList());
  }

  // 目標に ToDo アイテムを追加
  Future<void> addTodoToGoal(String goalId, ToDoItem todo) async {
    await _goalsCollection.doc(goalId).update({
      'todos': FieldValue.arrayUnion([todo.toMap()]),
    });
  }

  Stream<List<GoalItem>> getGoalsByCategory(String category) {
  return FirebaseFirestore.instance
      .collection('goals')
      .where('categories', arrayContains: category)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => GoalItem.fromDocument(doc)).toList());
}

  // // カテゴリーごとの目標を取得するメソッド
  // Future<List<GoalItem>> getGoalsByCategory(String category) async {
  //   List<GoalItem> goals = [];
  //   try {
  //     final querySnapshot = await _firestore
  //         .collection('goals')
  //         .where('categories', arrayContains: category)
  //         .get();

  //     goals = querySnapshot.docs.map((doc) => GoalItem.fromDocument(doc)).toList();
  //   } catch (e) {
  //     print('Error while fetching goals: $e');
  //   }
  //   return goals;
  // }
}

class GoalAndToDoList extends StatefulWidget {
  @override
  _GoalAndToDoListState createState() => _GoalAndToDoListState();
}

class _GoalAndToDoListState extends State<GoalAndToDoList> {
  final FirestoreService _firestoreService = FirestoreService();
  TextEditingController goalController = TextEditingController();
  TextEditingController todoController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  String selectedCategory = Categories.predefinedCategories.first;
  DateTime selectedDueDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('目標とToDoリスト'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: goalController,
            decoration: InputDecoration(hintText: '新しい目標を追加'),
          ),
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
              });
            },
            items: Categories.predefinedCategories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          ListTile(
            title: Text("完了予定日: ${DateFormat('yyyy/MM/dd').format(selectedDueDate)}"),
            trailing: Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
          TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'コメント'),
          ),
          ElevatedButton(
            onPressed: () {
              if (goalController.text.isNotEmpty) {
                _firestoreService.addGoalItem(
                  goalController.text,
                  [selectedCategory],
                  selectedDueDate,
                  commentController.text,
                  userId,
                );
                goalController.clear();
                commentController.clear();
              }
            },
            child: Text('目標を追加'),
          ),
          Expanded(
            child: StreamBuilder<List<GoalItem>>(
              stream: _firestoreService.getGoalItems(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('エラーが発生しました: ${snapshot.error}');
                }
                if (snapshot.hasData) {
                  final goals = snapshot.data!;
                  return ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return ExpansionTile(
                        title: Text(goal.title),
                        subtitle: Text('カテゴリー: ${goal.categories.join(', ')}\n完了予定日: ${DateFormat('yyyy/MM/dd').format(goal.dueDate!)}\nコメント: ${goal.comment ?? ''}'),
                        children: goal.todos.map((todo) {
                          return ListTile(
                            title: Text(todo.title),
                            leading: Checkbox(
                              value: todo.completed,
                              onChanged: (bool? value) {
                                _firestoreService.toggleCompleted(todo);
                              },
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _firestoreService.deleteTodoItem(todo.id);
                              },
                            ),
                          );
                        }).toList(),
                        trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            // ToDoを追加する処理
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return Text('データがありません。');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}




// class ToDoList extends StatefulWidget {
//   @override
//   _ToDoListState createState() => _ToDoListState();
// }

// class _ToDoListState extends State<ToDoList> {
//   final FirestoreService _firestoreService = FirestoreService();
//   TextEditingController todoController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('To-Doリスト'),
//       ),
//       body: Column(
//         children: <Widget>[
//           TextField(
//             controller: todoController,
//             decoration: InputDecoration(
//               hintText: '新しいタスクを追加',
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (todoController.text.isNotEmpty) {
//                 // ログイン中のユーザーIDを取得
//                 String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//                 _firestoreService.addTodoItem(todoController.text, userId);
//                 todoController.clear();
//               }
//             },
//             child: Text('追加'),
//           ),
//           Expanded(
//             child: StreamBuilder<List<ToDoItem>>(
//               stream: _firestoreService.getTodoItems(userId), // ユーザーIDを使用してToDoアイテムを取得
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   final todos = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: todos.length,
//                     itemBuilder: (context, index) {
//                       final item = todos[index];
//                       return ListTile(
//                         title: Text(item.title),
//                         leading: Checkbox(
//                           value: item.completed,
//                           onChanged: (bool? value) {
//                             _firestoreService.toggleCompleted(item);
//                           },
//                         ),
//                         trailing: IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             _firestoreService.deleteTodoItem(item.id);
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 } else if (snapshot.hasError) {
//                   return Text('エラーが発生しました！');
//                 } else {
//                   return CircularProgressIndicator();
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
