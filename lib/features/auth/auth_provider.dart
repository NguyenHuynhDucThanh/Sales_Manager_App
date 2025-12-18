import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_model.dart'; // 2. Import User Model (đảm bảo đã tạo file này ở Bước 1)

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // 3. Instance Firestore

  // Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // Theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 4. HÀM MỚI: Lấy thông tin chi tiết (Role) từ Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Lỗi lấy thông tin user: $e");
      return null;
    }
  }

  // Hàm Đăng nhập (Giữ nguyên)
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw Exception('Email không tồn tại');
      if (e.code == 'wrong-password') throw Exception('Sai mật khẩu');
      if (e.code == 'invalid-email') throw Exception('Email không hợp lệ');
      if (e.code == 'user-disabled') throw Exception('Tài khoản đã bị vô hiệu hóa');
      throw Exception(e.message ?? 'Đăng nhập thất bại');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 5. CẬP NHẬT HÀM ĐĂNG KÝ: Lưu role vào Firestore
  Future<void> signUp(String email, String password) async {
    try {
      // A. Tạo tài khoản Auth
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // B. Xác định Role (Logic: Email chứa "admin" -> Admin, còn lại -> User)
      // Trong thực tế có thể dùng một trang Admin riêng để cấp quyền, đây là cách nhanh nhất để test.
      String role = 'user';
      if (email.contains('admin')) {
        role = 'admin';
      }

      // C. Lưu vào Firestore collection 'users'
      if (credential.user != null) {
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email,
          role: role,
        );
        await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') throw Exception('Email này đã được đăng ký rồi');
      if (e.code == 'weak-password') throw Exception('Mật khẩu quá yếu (cần > 6 ký tự)');
      if (e.code == 'invalid-email') throw Exception('Email không hợp lệ');
      throw Exception(e.message ?? 'Đăng ký thất bại');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Hàm Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

// Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

// 6. PROVIDER QUAN TRỌNG: Cung cấp thông tin User (Role) cho UI
final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  // Lắng nghe auth state
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) return null;

  // Nếu đã đăng nhập -> Gọi Repo lấy thông tin từ Firestore
  final repo = ref.read(authRepositoryProvider);
  return await repo.getUserData(user.uid);
});