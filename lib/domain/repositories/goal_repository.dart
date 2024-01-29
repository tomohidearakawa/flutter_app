import '../entities/goal_item.dart';

abstract class GoalRepository {
  Future<void> addGoal(GoalItem goal);
  Stream<List<GoalItem>> getGoals();
  Future<void> updateGoal(GoalItem goal);
  Future<void> deleteGoal(String goalId);
  Future<GoalItem> getGoalById(String goalId);
  // 他のビジネスロジックに関連するメソッド
}
