import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindwealth_ai/services/firebase_service.dart';
import 'package:mindwealth_ai/models/user_model.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  return service.authStateChanges;
});

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final service = ref.watch(firebaseServiceProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return service.userProfileStream();
    },
    loading: () => Stream.value(null),
    error: (e, s) => Stream.value(null),
  );
});

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    final service = ref.watch(firebaseServiceProvider);
    service.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
    return const AsyncValue.loading();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(firebaseServiceProvider);
      await service.signInWithEmail(email, password);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(firebaseServiceProvider);
      await service.registerWithEmail(email, password, name);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    try {
      final service = ref.read(firebaseServiceProvider);
      await service.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final service = ref.read(firebaseServiceProvider);
      await service.updateProfile(data);
    } catch (_) {
      // Handle error
    }
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(
  () {
    return AuthNotifier();
  },
);
