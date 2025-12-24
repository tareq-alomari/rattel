import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

/// Authentication controller for login, registration, and session management
class AuthController extends GetxController {
  // Observable states
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedRole = 'student'.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedInStatus = await AuthService.instance.isLoggedIn();

      if (isLoggedInStatus) {
        // Load current user data if logged in
        final user = AuthService.instance.currentUser;
        if (user != null) {
          currentUser.value = user;
          isLoggedIn.value = true;
          selectedRole.value = user.role;
          debugPrint('✅ User session found: ${user.userId}');
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
    }
  }

  /// Login with username/email and password
  Future<void> login(String emailOrUsername, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate inputs
      if (emailOrUsername.trim().isEmpty || password.trim().isEmpty) {
        errorMessage.value = 'please_enter_credentials'.tr;
        Get.snackbar('error'.tr, errorMessage.value);
        return;
      }

      // Login using AuthService
      final user = await AuthService.instance.login(
        email: emailOrUsername,
        password: password,
      );

      if (user != null) {
        currentUser.value = user;
        isLoggedIn.value = true;

        // Save role to state
        selectedRole.value = user.role;

        debugPrint('✅ Login successful: ${user.email}');

        // Navigate based on role
        if (user.role == 'student') {
          Get.offAllNamed(AppRoutes.studentHome);
        } else {
          Get.offAllNamed(AppRoutes.teacherHome);
        }

        Get.snackbar('login_success'.tr, 'welcome'.tr);
      }
    } catch (e) {
      errorMessage.value = 'login_failed'.tr;
      Get.snackbar('error'.tr, errorMessage.value);
      debugPrint('❌ Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate inputs
      if (name.trim().isEmpty ||
          email.trim().isEmpty ||
          password.trim().isEmpty) {
        errorMessage.value = 'please_fill_all_fields'.tr;
        Get.snackbar('error'.tr, errorMessage.value);
        return;
      }

      if (password.length < 6) {
        errorMessage.value = 'password_too_short'.tr;
        Get.snackbar('error'.tr, errorMessage.value);
        return;
      }

      // Register using AuthService
      final user = await AuthService.instance.register(
        name: name,
        email: email,
        password: password,
        role: selectedRole.value,
      );

      if (user != null) {
        debugPrint('✅ User registered: $email (${selectedRole.value})');

        // Auto-login logic included in AuthService register?
        // AuthService.register returns a user and saves session, but just to be sure
        // let's follow the previous pattern of updating local state
        currentUser.value = user;
        isLoggedIn.value = true;

        if (user.role == 'student') {
          Get.offAllNamed(AppRoutes.studentHome);
        } else {
          Get.offAllNamed(AppRoutes.teacherHome);
        }

        Get.snackbar('success'.tr, 'account_created'.tr);
      }
    } catch (e) {
      errorMessage.value = 'registration_failed'.tr;
      Get.snackbar('error'.tr, errorMessage.value);
      debugPrint('❌ Registration error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await AuthService.instance.logout();

      currentUser.value = null;
      isLoggedIn.value = false;

      debugPrint('✅ User logged out');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
  }

  /// Check if current user is a student
  bool get isStudent =>
      currentUser.value?.isStudent ?? selectedRole.value == 'student';

  /// Check if current user is a teacher
  bool get isTeacher =>
      currentUser.value?.isTeacher ?? selectedRole.value == 'teacher';

  /// Get current user ID
  int? get userId => currentUser.value?.userId ?? 1;

  /// Get current username
  String get username => currentUser.value?.username ?? 'User';

  /// Get current user full name
  String get fullName => currentUser.value?.fullName ?? 'User';

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Set selected role for registration
  void setRole(String role) {
    selectedRole.value = role;
  }
}
