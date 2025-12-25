import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';

/// LoginLogic - Business logic cho authentication
class LoginLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Validate email và password
  String? validateCredentials(String email, String password) {
    if (email.trim().isEmpty) return 'Vui lòng nhập Email';
    if (!email.contains('@')) return 'Email không hợp lệ';
    if (password.length < 6) return 'Mật khẩu phải >= 6 ký tự';
    return null; // Valid
  }

  /// Đăng nhập
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw Exception('Email không tồn tại');
      if (e.code == 'wrong-password') throw Exception('Sai mật khẩu');
      if (e.code == 'invalid-email') throw Exception('Email không hợp lệ');
      if (e.code == 'user-disabled') throw Exception('Tài khoản đã bị vô hiệu hóa');
      if (e.code == 'operation-not-allowed') {
        throw Exception('Email/Password đang bị tắt. Vào Firebase Console → Authentication → Sign-in method và bật Email/Password.');
      }
      if (e.code == 'too-many-requests') {
        throw Exception('Bạn đã thử quá nhiều lần. Vui lòng thử lại sau ít phút.');
      }
      if (e.code == 'network-request-failed') {
        throw Exception('Lỗi mạng. Kiểm tra kết nối Internet.');
      }
      if (e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        throw Exception('Thông tin đăng nhập không hợp lệ. Kiểm tra email/mật khẩu.');
      }
      throw Exception(e.message ?? 'Đăng nhập thất bại');
    }
  }

  /// Đăng ký
  Future<void> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Xác định role
      String role = email.contains('admin') ? 'admin' : 'user';

      // Lưu vào Firestore
      if (credential.user != null) {
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email.trim(),
          role: role,
        );
        await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') throw Exception('Email này đã được đăng ký rồi');
      if (e.code == 'weak-password') throw Exception('Mật khẩu quá yếu (cần > 6 ký tự)');
      if (e.code == 'invalid-email') throw Exception('Email không hợp lệ');
      throw Exception(e.message ?? 'Đăng ký thất bại');
    }
  }

  /// Lấy thông tin user từ Firestore
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

  /// Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
