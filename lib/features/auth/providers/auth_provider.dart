import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/user_model.dart';
import '../logic/login_logic.dart';

// AuthRepository wrapper
class AuthRepository {
  final LoginLogic _logic = LoginLogic();

  User? get currentUser => FirebaseAuth.instance.currentUser;
  Stream<User?> get authStateChanges => _logic.authStateChanges;

  Future<UserModel?> getUserData(String uid) => _logic.getUserData(uid);
  Future<void> signIn(String email, String password) => _logic.signIn(email, password);
  Future<void> signUp(String email, String password) => _logic.signUp(email, password);
  Future<void> signOut() => _logic.signOut();
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) return null;

  final repo = ref.read(authRepositoryProvider);
  return await repo.getUserData(user.uid);
});
