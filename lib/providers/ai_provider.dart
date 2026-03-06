import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindwealth_ai/models/ai_insight_model.dart';
import 'package:mindwealth_ai/services/ai_service.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref.watch(firebaseServiceProvider));
});

final aiInsightsStreamProvider = StreamProvider<List<AiInsightModel>>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return service.aiInsightsStream();
});

class AiAnalysisLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final aiAnalysisLoadingProvider =
    NotifierProvider<AiAnalysisLoadingNotifier, bool>(
      AiAnalysisLoadingNotifier.new,
    );
