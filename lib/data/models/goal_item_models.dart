import '../../domain/entities/goal_item.dart';
import 'todo_item_model.dart';

class GoalItemModel extends GoalItem {
  GoalItemModel({
    required String id,
    required String title,
    List<String> categories,
    List<ToDoItemModel> todos,
    DateTime? dueDate,
    String? comment,
    String? userId,
    String? userName,
  }) : super(
          id: id,
          title: title,
          categories: categories,
          todos: todos,
          dueDate: dueDate,
          comment: comment,
          userId: userId,
          userName: userName,
        );

  factory GoalItemModel.fromMap(Map<String, dynamic> map) {
    return GoalItemModel(
      id: map['id'],
      title: map['title'],
      categories: List<String>.from(map['categories']),
      todos: (map['todos'] as List).map((todo) => ToDoItemModel.fromMap(todo)).toList(),
      dueDate: map['dueDate'].toDate(),
      comment: map['comment'],
      userId: map['userId'],
      userName: map['userName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'categories': categories,
      'todos': todos.map((todo) => (todo as ToDoItemModel).toMap()).toList(),
      'dueDate': dueDate,
      'comment': comment,
      'userId': userId,
      'userName': userName,
    };
  }
}
