import '../../domain/entities/todo_item.dart';

class ToDoItemModel extends ToDoItem {
  ToDoItemModel({
    required String id,
    required String title,
    bool completed,
  }) : super(id: id, title: title, completed: completed);

  factory ToDoItemModel.fromMap(Map<String, dynamic> map) {
    return ToDoItemModel(
      id: map['id'],
      title: map['title'],
      completed: map['completed'] ?? false,
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
