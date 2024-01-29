import '../repositories/goal_repository.dart';
import '../entities/goal_item.dart';

class GetGoals {
  final GoalRepository repository;

  GetGoals(this.repository);

  Stream<List<GoalItem>> call() {
    return repository.getGoals();
  }
}
