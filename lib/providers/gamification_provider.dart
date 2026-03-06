import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindwealth_ai/models/gamification_model.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';

final gamificationStreamProvider = StreamProvider<GamificationModel>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return service.gamificationStream();
});
