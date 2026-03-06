import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindwealth_ai/models/user_model.dart';
import 'package:mindwealth_ai/models/transaction_model.dart';
import 'package:mindwealth_ai/models/goal_model.dart';
import 'package:mindwealth_ai/models/gamification_model.dart';
import 'package:mindwealth_ai/models/ai_insight_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Auth ───
  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Create user document
    await _db.collection('users').doc(cred.user!.uid).set({
      'profile': {'email': email, 'name': name, 'income': 0},
      'transactions': [],
      'goals': [],
      'gamification': {'points': 0, 'badges': []},
      'theme': 'dark',
    });
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  // ─── User Profile ───
  Future<UserModel?> getUserProfile() async {
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(uid!, doc.data()!);
  }

  Stream<UserModel?> userProfileStream() {
    if (uid == null) return Stream.value(null);
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(uid!, doc.data()!);
    });
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      for (final entry in data.entries) 'profile.${entry.key}': entry.value,
    });
  }

  Future<void> updateTheme(String theme) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'theme': theme});
  }

  Future<void> updateBudgets(Map<String, double> budgets) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'profile.budgets': budgets});
  }

  // ─── Transactions ───
  Future<List<TransactionModel>> getTransactions() async {
    if (uid == null) return [];
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return [];
    final data = doc.data()!;
    final list = data['transactions'] as List<dynamic>? ?? [];
    return list
        .map((e) => TransactionModel.fromMap(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Stream<List<TransactionModel>> transactionsStream() {
    if (uid == null) return Stream.value([]);
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return <TransactionModel>[];
      final data = doc.data()!;
      final list = data['transactions'] as List<dynamic>? ?? [];
      return list
          .map((e) => TransactionModel.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> addTransaction(TransactionModel txn) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'transactions': FieldValue.arrayUnion([txn.toMap()]),
    });
  }

  Future<void> updateTransaction(
    TransactionModel oldTxn,
    TransactionModel newTxn,
  ) async {
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return;
    final list = List<Map<String, dynamic>>.from(
      doc.data()!['transactions'] ?? [],
    );
    final index = list.indexWhere((e) => e['id'] == oldTxn.id);
    if (index != -1) {
      list[index] = newTxn.toMap();
      await _db.collection('users').doc(uid).update({'transactions': list});
    }
  }

  Future<void> deleteTransaction(String txnId) async {
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return;
    final list = List<Map<String, dynamic>>.from(
      doc.data()!['transactions'] ?? [],
    );
    list.removeWhere((e) => e['id'] == txnId);
    await _db.collection('users').doc(uid).update({'transactions': list});
  }

  // ─── Goals ───
  Future<List<GoalModel>> getGoals() async {
    if (uid == null) return [];
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return [];
    final data = doc.data()!;
    final list = data['goals'] as List<dynamic>? ?? [];
    return list
        .map((e) => GoalModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Stream<List<GoalModel>> goalsStream() {
    if (uid == null) return Stream.value([]);
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return <GoalModel>[];
      final data = doc.data()!;
      final list = data['goals'] as List<dynamic>? ?? [];
      return list
          .map((e) => GoalModel.fromMap(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> addGoal(GoalModel goal) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'goals': FieldValue.arrayUnion([goal.toMap()]),
    });
  }

  Future<void> updateGoal(GoalModel oldGoal, GoalModel newGoal) async {
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return;
    final list = List<Map<String, dynamic>>.from(doc.data()!['goals'] ?? []);
    final index = list.indexWhere((e) => e['id'] == oldGoal.id);
    if (index != -1) {
      list[index] = newGoal.toMap();
      await _db.collection('users').doc(uid).update({'goals': list});
    }
  }

  Future<void> deleteGoal(String goalId) async {
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return;
    final list = List<Map<String, dynamic>>.from(doc.data()!['goals'] ?? []);
    list.removeWhere((e) => e['id'] == goalId);
    await _db.collection('users').doc(uid).update({'goals': list});
  }

  // ─── Gamification ───
  Stream<GamificationModel> gamificationStream() {
    if (uid == null) return Stream.value(GamificationModel());
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return GamificationModel();
      return GamificationModel.fromMap(
        doc.data()!['gamification'] as Map<String, dynamic>?,
      );
    });
  }

  Future<void> updateGamification(GamificationModel gamification) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'gamification': gamification.toMap(),
    });
  }

  Future<void> addBadge(String badge) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'gamification.badges': FieldValue.arrayUnion([badge]),
    });
  }

  Future<void> addPoints(int pts) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'gamification.points': FieldValue.increment(pts),
    });
  }

  // ─── AI Insights ───
  Stream<List<AiInsightModel>> aiInsightsStream() {
    if (uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(uid)
        .collection('aiInsights')
        .orderBy('generatedAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => AiInsightModel.fromMap(d.data())).toList(),
        );
  }

  Future<void> saveAiInsight(AiInsightModel insight) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('aiInsights')
        .doc(insight.id)
        .set(insight.toMap());
  }
}
