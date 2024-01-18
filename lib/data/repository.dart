// import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreのインポート


// class FirestoreService {
//   final CollectionReference _todosCollection = FirebaseFirestore.instance.collection('todos');
//   final CollectionReference _goalsCollection = FirebaseFirestore.instance.collection('goals');

//   // ToDo アイテムを追加
//   Future<void> addTodoItem(String title, String userId) async {
//     await _todosCollection.add({'title': title, 'completed': false, 'userId': userId});
//   }

//   // 特定のユーザーの ToDo アイテムを取得
//   Stream<List<ToDoItem>> getTodoItems(String userId) {
//     return _todosCollection
//         .where('userId', isEqualTo: userId)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.map((doc) => ToDoItem.fromDocument(doc)).toList());
//   }

//   // ToDo アイテムを削除
//   Future<void> deleteTodoItem(String id) async {
//     await _todosCollection.doc(id).delete();
//   }

//   // ToDo アイテムの完了状態をトグル
//   Future<void> toggleCompleted(ToDoItem item) async {
//     await _todosCollection.doc(item.id).update({'completed': !item.completed});
//   }

//   // 目標を追加
//   Future<void> addGoalItem(String title, List<String> categories, DateTime dueDate, String comment, String userId) async {
//     await _goalsCollection.add({
//       'title': title,
//       'categories': categories,
//       'dueDate': dueDate,
//       'comment': comment,
//       'userId': userId,
//       'todos': [], // 空の ToDo アイテムリストを追加
//     });
//   }


//   // 特定のユーザーの目標を取得
//   Stream<List<GoalItem>> getGoalItems(String userId) {
//     return _goalsCollection
//         .where('userId', isEqualTo: userId)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.map((doc) => GoalItem.fromDocument(doc)).toList());
//   }

//   // 目標に ToDo アイテムを追加
//   Future<void> addTodoToGoal(String goalId, ToDoItem todo) async {
//     await _goalsCollection.doc(goalId).update({
//       'todos': FieldValue.arrayUnion([todo.toMap()]),
//     });
//   }
// }
