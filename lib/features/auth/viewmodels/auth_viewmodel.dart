import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/base/base_viewmodel.dart';
import '../../../core/models/user_model.dart';
import '../logic/login_logic.dart';

/// AuthViewModel - ViewModel cho authentication
/// Quản lý state và business logic cho màn hình đăng nhập/đăng ký
class AuthViewModel extends BaseViewModel {
  final LoginLogic _loginLogic = LoginLogic();

  User? _currentUser;
  UserModel? _currentUserData;

  User? get currentUser => _currentUser;
  UserModel? get currentUserData => _currentUserData;

  /// Stream để lắng nghe thay đổi auth state
  Stream<User?> get authStateChanges => _loginLogic.authStateChanges;

  /// Validate email và password
  String? validateCredentials(String email, String password) {
    return _loginLogic.validateCredentials(email, password);
  }

  /// Đăng nhập
  Future<bool> signIn(String email, String password) async {
    try {
      setLoading(true);
      clearError();

      // Validate
      final validationError = validateCredentials(email, password);
      if (validationError != null) {
        setError(validationError);
        return false;
      }

      await _loginLogic.signIn(email, password);
      _currentUser = FirebaseAuth.instance.currentUser;
      
      if (_currentUser != null) {
        _currentUserData = await _loginLogic.getUserData(_currentUser!.uid);
      }

      return true;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      setError(errorMsg);
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Đăng ký
  Future<bool> signUp(String email, String password) async {
    try {
      setLoading(true);
      clearError();

      // Validate
      final validationError = validateCredentials(email, password);
      if (validationError != null) {
        setError(validationError);
        return false;
      }

      await _loginLogic.signUp(email, password);
      _currentUser = FirebaseAuth.instance.currentUser;
      
      if (_currentUser != null) {
        _currentUserData = await _loginLogic.getUserData(_currentUser!.uid);
      }

      return true;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      setError(errorMsg);
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      setLoading(true);
      clearError();
      await _loginLogic.signOut();
      _currentUser = null;
      _currentUserData = null;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      setError(errorMsg);
    } finally {
      setLoading(false);
    }
  }

  /// Lấy thông tin user hiện tại
  Future<void> loadCurrentUser() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser != null) {
        _currentUserData = await _loginLogic.getUserData(_currentUser!.uid);
        notifyListeners();
      }
    } catch (e) {
      setError('Không thể tải thông tin người dùng');
    }
  }

  /// Lắng nghe auth state changes và cập nhật current user
  void listenToAuthState() {
    // Load user hiện tại ngay lập tức
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      loadCurrentUser();
    }

    // Lắng nghe thay đổi
    authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        loadCurrentUser();
      } else {
        _currentUserData = null;
        notifyListeners();
      }
    });
  }
}

