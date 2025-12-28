import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

/// Auth controller for login/register
class AuthController extends GetxController {
  final AuthService _authService = AuthService.instance;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'student'.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _authService.currentUser;
  }

  /// Login user
  Future<void> login(
    String email,
    String password, {
    bool useFirebase = true,
  }) async {
    try {
      isLoading.value = true;
      UserModel? user;

      if (useFirebase) {
        user = await _firebaseAuthService.signInWithEmail(email, password);
      } else {
        user = await _authService.login(email: email, password: password);
      }

      currentUser.value = user;

      if (user != null) {
        // Navigate based on role
        if (user.isStudent == true) {
          Get.offAllNamed(AppRoutes.studentHome);
        } else {
          Get.offAllNamed(AppRoutes.teacherHome);
        }
        Get.snackbar('login_success'.tr, 'welcome'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'invalid_credentials'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user
  Future<void> register(
    String name,
    String email,
    String password, {
    bool useFirebase = true,
  }) async {
    try {
      isLoading.value = true;
      UserModel? user;

      if (useFirebase) {
        user = await _firebaseAuthService.signUpWithEmail(
          email,
          password,
          name,
          selectedRole.value,
        );
      } else {
        user = await _authService.register(
          name: name,
          email: email,
          password: password,
          role: selectedRole.value,
        );
      }

      currentUser.value = user;

      if (user != null) {
        // Navigate based on role
        if (user.isStudent == true) {
          Get.offAllNamed(AppRoutes.studentHome);
        } else {
          Get.offAllNamed(AppRoutes.teacherHome);
        }
        Get.snackbar('register_success'.tr, 'welcome'.tr);
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'خطأ في الحساب',
        _getArabicErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (e.toString().contains('email_already_exists')) {
        Get.snackbar('error'.tr, 'email_already_exists'.tr);
      } else {
        Get.snackbar('error'.tr, e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // Check if Firebase is ready
      if (Firebase.apps.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'خدمات جوجل غير متاحة حالياً على هذا الجهاز. يرجى التأكد من الإعدادات.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final user = await _firebaseAuthService.signInWithGoogle();
      currentUser.value = user;

      if (user != null) {
        if (user.isStudent == true) {
          Get.offAllNamed(AppRoutes.studentHome);
        } else {
          Get.offAllNamed(AppRoutes.teacherHome);
        }
        Get.snackbar('login_success'.tr, 'welcome'.tr);
      } else {
        // user is null but no exception was thrown (e.g. user cancelled)
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'خطأ في جوجل',
        _getArabicErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        Get.snackbar(
          'تنبيه',
          'تسجيل الدخول بجوجل غير مدعوم حالياً على نظام الويندوز. يرجى استخدام البريد الإلكتروني وكلمة المرور.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
        );
      } else {
        Get.snackbar('error'.tr, e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      debugPrint('🚪 Logging out...');
      await _authService.logout();
      await _firebaseAuthService.signOut();
    } catch (e) {
      debugPrint('⚠️ Error during logout services: $e');
    } finally {
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
      debugPrint('✅ Logout complete, navigating to login');
    }
  }

  /// Update user profile
  Future<void> updateProfile(String name) async {
    try {
      isLoading.value = true;
      await _authService.updateProfile(name: name);
      currentUser.value = _authService.currentUser;
      Get.snackbar('success'.tr, 'profile_updated'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'update_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper to map Firebase errors to Arabic
  String _getArabicErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'المستخدم غير موجود. يرجى التحقق من البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل.';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً. يجب أن تكون 6 أحرف على الأقل.';
      case 'operation-not-allowed':
        return 'طريقة تسجيل الدخول هذه غير مفعلة في Firebase Console.';
      case 'network-request-failed':
        return 'فشل الاتصال بالشبكة. يرجى التحقق من الإنترنت.';
      default:
        return 'حدث خطأ في Firebase: $code';
    }
  }
}
