import '../repositories/goal_repository.dart';
import '../entities/goal_item.dart';

class AddGoal {
  final GoalRepository repository;

  AddGoal(this.repository);

  Future<void> call(GoalItem goal) async {
    await repository.addGoal(goal);
  }
}
