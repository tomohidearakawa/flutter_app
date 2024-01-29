import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/goal_item_model.dart';
import '../../models/todo_item_model.dart';

class FirestoreService {
  final CollectionReference _goalsCollection = FirebaseFirestore.instance.collection('goals');
  final CollectionReference _todosCollection = FirebaseFirestore.instance.collection('todos');

  // Firestore関連のメソッド実装
  // 例: GoalItemを追加
  Future<void> addGoal(GoalItemModel goal) async {
    await _goalsCollection.add(goal.toMap());
  }

  // 他のCRUD操作も同様に実装
}
