import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

/// Auth controller for login/register
class AuthController extends GetxController {
  final AuthService _authService = AuthService.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'student'.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _authService.currentUser;
  }

  /// Login user
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.login(email: email, password: password);
      currentUser.value = user;

      // Navigate based on role
      if (user?.isStudent == true) {
        Get.offAllNamed(AppRoutes.studentHome);
      } else {
        Get.offAllNamed(AppRoutes.teacherHome);
      }

      Get.snackbar('login_success'.tr, 'welcome'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'invalid_credentials'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: selectedRole.value,
      );
      currentUser.value = user;

      // Navigate based on role
      if (user?.isStudent == true) {
        Get.offAllNamed(AppRoutes.studentHome);
      } else {
        Get.offAllNamed(AppRoutes.teacherHome);
      }

      Get.snackbar('register_success'.tr, 'welcome'.tr);
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

  /// Logout user
  Future<void> logout() async {
    await _authService.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
