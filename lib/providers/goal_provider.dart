import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindwealth_ai/models/goal_model.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';

final goalsStreamProvider = StreamProvider<List<GoalModel>>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return service.goalsStream();
});

final totalSavedProvider = Provider<double>((ref) {
  final goals = ref.watch(goalsStreamProvider).value ?? [];
  return goals.fold(0.0, (sum, g) => sum + g.saved);
});

final completedGoalsProvider = Provider<int>((ref) {
  final goals = ref.watch(goalsStreamProvider).value ?? [];
  return goals.where((g) => g.isCompleted).length;
});
