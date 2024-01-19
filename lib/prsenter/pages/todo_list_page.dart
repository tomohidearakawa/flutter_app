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
  String? userId; // ユーザーIDを追加
  String? userName; // ユーザー名を追加

  GoalItem({
    required this.id,
    required this.title,
    this.categories = const [],
    this.todos = const [],
    this.dueDate,
    this.comment,
    this.userId, // ユーザーIDを受け取る引数を追加
    this.userName, // ユーザー名を受け取る引数を追加
  });

  factory GoalItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return GoalItem(
      id: doc.id,
      title: data?['title'] ?? '', // データが null の場合にデフォルトの空文字列を設定
      categories: List<String>.from(data?['categories'] ?? []),
      todos: (data?['todos'] as List? ?? []).map((todo) => ToDoItem.fromMap(todo)).toList(),
      dueDate: data?['dueDate']?.toDate() ?? null,
      comment: data?['comment'] ?? null,
      userId: data?['userId'] ?? null,
      userName: data?['userName'] ?? null,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'categories': categories,
      'todos': todos.map((todo) => todo.toMap()).toList(),
      'dueDate': dueDate,
      'comment': comment,
      'userId': userId, // データが null の場合でもそのまま設定
      'userName': userName, // データが null の場合でもそのまま設定
    };
  }
}

class Comment {
  final String id; // コメントの一意のID
  final String userName; // コメントしたユーザーの名前
  final String commentText; // コメントのテキスト
  final DateTime timestamp; // コメントのタイムスタンプ

  Comment({
    required this.id,
    required this.userName,
    required this.commentText,
    required this.timestamp,
  });
}


class Categories {
  static const List<String> predefinedCategories = [
    'book', 'programming', 'serach', 'other'
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

  Future<String?> getUserName(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()?['username'];
    }
    return null;
  }

  // 目標を追加
  Future<void> addGoalItem(String title, List<String> categories, DateTime dueDate, String comment, String userId) async {
    final userName = await getUserName(userId); // ユーザー名を取得
    await _goalsCollection.add({
      'title': title,
      'categories': categories,
      'dueDate': dueDate,
      'comment': comment,
      'userId': userId,
      'userName': userName, // ユーザー名を保存
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

  Future<void> addCommentToGoal(String goalId, String comment, String userName) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(goalId).update({
        'comments': FieldValue.arrayUnion([
          {
            'comment': comment,
            'userName': userName,
            'timestamp': Timestamp.now(),
          },
        ]),
      });
    } catch (e) {
      print('コメントの追加中にエラーが発生しました: $e'); // エラーメッセージを出力
    }
  }

  Future<void> deleteComment(String goalId, String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('goals')
          .doc(goalId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print('コメントの削除中にエラーが発生しました: $e'); // エラーメッセージを出力
    }
  }

  Stream<List<Comment>> getCommentsForGoal(String goalId) {
    return FirebaseFirestore.instance.collection('goals').doc(goalId).snapshots().asyncMap((snapshot) async {
      final data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('comments')) {
        final commentsData = List<Map<String, dynamic>>.from(data['comments']);
        final comments = await Future.wait(commentsData.map((commentData) async {
          // コメントデータからCommentオブジェクトを生成
          final userId = commentData['userId'] as String?;
          final userName = userId != null ? (await getUserName(userId)) ?? '不明' : '不明'; // ユーザー名が null の場合、'不明' をデフォルト値として設定
          return Comment(
            id: commentData['id'],
            userName: userName,
            commentText: commentData['commentText'],
            timestamp: commentData['timestamp'].toDate(),
          );
        }));

        return comments;
      } else {
        return <Comment>[];
      }
    });
  }


  Future<void> updateGoalItem(String goalId, String editedTitle, DateTime editedDueDate, String editedComment) async {
    await _goalsCollection.doc(goalId).update({
      'title': editedTitle,
      'dueDate': editedDueDate,
      'comment': editedComment,
    });
  }

  // 目標に ToDo アイテムを追加
  Future<void> addTodoToGoal(String goalId, ToDoItem todo) async {
    await _goalsCollection.doc(goalId).update({
      'todos': FieldValue.arrayUnion([todo.toMap()]),
    });
  }

  Future<void> deleteGoalItem(String goalId) async {
    await _goalsCollection.doc(goalId).delete();
  }

  Stream<List<GoalItem>> getGoalsByCategory(String category) {
    return FirebaseFirestore.instance
        .collection('goals')
        .where('categories', arrayContains: category)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GoalItem.fromDocument(doc)).toList());
  }
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

  // 1. ユーザーが目標をタップしたときに、目標修正用のダイアログを表示
  Future<void> _editGoal(GoalItem goal) async {
    String editedTitle = goal.title;
    DateTime editedDueDate = goal.dueDate ?? DateTime.now();
    String editedComment = goal.comment ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('目標修正'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: '目標名'),
                onChanged: (value) {
                  editedTitle = value;
                },
                controller: TextEditingController(text: editedTitle),
              ),
              ListTile(
                title: Text("完了予定日: ${DateFormat('yyyy/MM/dd').format(editedDueDate)}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: editedDueDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != editedDueDate) {
                    setState(() {
                      editedDueDate = picked;
                    });
                  }
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'コメント'),
                onChanged: (value) {
                  editedComment = value;
                },
                controller: TextEditingController(text: editedComment),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                // 2. フォームのデータを使って Firestore に目標情報を更新
                _updateGoal(goal.id, editedTitle, editedDueDate, editedComment);
                Navigator.pop(context);
              },
              child: Text('保存'),
            ),
          ],
        );
      },
    );
  }

  // 3. フォームのデータを使って Firestore に目標情報を更新
  Future<void> _updateGoal(String goalId, String editedTitle, DateTime editedDueDate, String editedComment) async {
    await _firestoreService.updateGoalItem(goalId, editedTitle, editedDueDate, editedComment);
  }

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

  Future<void> _deleteGoal(String goalId) async {
    await _firestoreService.deleteGoalItem(goalId);
  }

  Future<void> _addTodoToGoal(String goalId, String todoTitle) async {
    if (todoTitle.isNotEmpty) {
      // 新しい ToDoItem を作成し、データベースに追加
      final newTodo = ToDoItem(id: '', title: todoTitle, completed: false);
      await _firestoreService.addTodoToGoal(goalId, newTodo);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('目標とToDoリスト'),
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
                        subtitle: Text(
                            'カテゴリー: ${goal.categories.join(', ')}\n完了予定日: ${DateFormat('yyyy/MM/dd').format(goal.dueDate!)}\nコメント: ${goal.comment ?? ''}'),
                        children: [
                          ListTile(
                            title: Text('ToDoリスト'),
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                // ToDoを追加するダイアログを表示
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('ToDoを追加'),
                                      content: TextField(
                                        controller: todoController,
                                        decoration: InputDecoration(hintText: '新しいToDoを入力'),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('キャンセル'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _addTodoToGoal(goal.id, todoController.text);
                                            todoController.clear();
                                            Navigator.pop(context);
                                          },
                                          child: Text('追加'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Column(
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
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // 4. 目標修正ボタンを追加
                              TextButton(
                                onPressed: () {
                                  _editGoal(goal);
                                },
                                child: Text('目標修正'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteGoal(goal.id);
                                },
                                child: Text('目標を削除'),
                              ),
                            ],
                          ),
                        ],
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

// class GoalAndToDoList extends StatefulWidget {
//   @override
//   _GoalAndToDoListState createState() => _GoalAndToDoListState();
// }

// class _GoalAndToDoListState extends State<GoalAndToDoList> {
//   final FirestoreService _firestoreService = FirestoreService();
//   TextEditingController goalController = TextEditingController();
//   TextEditingController todoController = TextEditingController();
//   TextEditingController commentController = TextEditingController();
//   String selectedCategory = Categories.predefinedCategories.first;
//   DateTime selectedDueDate = DateTime.now();

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDueDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2025),
//     );
//     if (picked != null && picked != selectedDueDate) {
//       setState(() {
//         selectedDueDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('目標とToDoリスト'),
//       ),
//       body: Column(
//         children: <Widget>[
//           TextField(
//             controller: goalController,
//             decoration: InputDecoration(hintText: '新しい目標を追加'),
//           ),
//           DropdownButton<String>(
//             value: selectedCategory,
//             onChanged: (String? newValue) {
//               setState(() {
//                 selectedCategory = newValue!;
//               });
//             },
//             items: Categories.predefinedCategories.map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//           ListTile(
//             title: Text("完了予定日: ${DateFormat('yyyy/MM/dd').format(selectedDueDate)}"),
//             trailing: Icon(Icons.calendar_today),
//             onTap: () => _selectDate(context),
//           ),
//           TextField(
//             controller: commentController,
//             decoration: InputDecoration(hintText: 'コメント'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (goalController.text.isNotEmpty) {
//                 _firestoreService.addGoalItem(
//                   goalController.text,
//                   [selectedCategory],
//                   selectedDueDate,
//                   commentController.text,
//                   userId,
//                 );
//                 goalController.clear();
//                 commentController.clear();
//               }
//             },
//             child: Text('目標を追加'),
//           ),
//           Expanded(
//             child: StreamBuilder<List<GoalItem>>(
//               stream: _firestoreService.getGoalItems(userId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 }
//                 if (snapshot.hasError) {
//                   return Text('エラーが発生しました: ${snapshot.error}');
//                 }
//                 if (snapshot.hasData) {
//                   final goals = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: goals.length,
//                     itemBuilder: (context, index) {
//                       final goal = goals[index];
//                       return ExpansionTile(
//                         title: Text(goal.title),
//                         subtitle: Text('カテゴリー: ${goal.categories.join(', ')}\n完了予定日: ${DateFormat('yyyy/MM/dd').format(goal.dueDate!)}\nコメント: ${goal.comment ?? ''}'),
//                         children: goal.todos.map((todo) {
//                           return ListTile(
//                             title: Text(todo.title),
//                             leading: Checkbox(
//                               value: todo.completed,
//                               onChanged: (bool? value) {
//                                 _firestoreService.toggleCompleted(todo);
//                               },
//                             ),
//                             trailing: IconButton(
//                               icon: Icon(Icons.delete),
//                               onPressed: () {
//                                 _firestoreService.deleteTodoItem(todo.id);
//                               },
//                             ),
//                           );
//                         }).toList(),
//                         trailing: IconButton(
//                           icon: Icon(Icons.add),
//                           onPressed: () {
//                             // ToDoを追加する処理
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 } else {
//                   return Text('データがありません。');
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




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
