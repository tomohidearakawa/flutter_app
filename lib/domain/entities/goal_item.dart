import 'todo_item.dart';

class GoalItem {
  final String id;
  final String title;
  final List<String> categories;
  final List<ToDoItem> todos;
  final DateTime? dueDate;
  final String? comment;
  final String? userId;
  final String? userName;

  GoalItem({
    required this.id,
    required this.title,
    this.categories = const [],
    this.todos = const [],
    this.dueDate,
    this.comment,
    this.userId,
    this.userName,
  });
}
