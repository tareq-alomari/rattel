import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/student/views/student_main_view.dart';
import '../modules/student/controllers/student_controller.dart';

import '../modules/teacher/views/teacher_main_view.dart';
import '../modules/teacher/controllers/teacher_controller.dart';
import '../modules/quran/views/surah_selector_view.dart';
import '../modules/quran/controllers/quran_controller.dart';
import '../modules/search/views/search_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/controllers/settings_controller.dart';

import '../modules/teacher/views/student_list_view.dart';
import '../modules/teacher/controllers/student_list_controller.dart';
import '../modules/teacher/views/student_detail_view.dart';
import '../modules/teacher/controllers/student_detail_controller.dart';
import '../modules/teacher/views/evaluation_view.dart';
import '../modules/teacher/controllers/evaluation_controller.dart';
import '../modules/student/views/badges_view.dart';
import '../modules/student/controllers/badges_controller.dart';
import 'middlewares/auth_middleware.dart';

/// App pages configuration
abstract class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.studentHome,
      page: () => const StudentMainView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StudentController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.teacherHome,
      page: () => const TeacherMainView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TeacherController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.surahSelector,
      page: () => const SurahSelectorView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => QuranController());
      }),
    ),
    GetPage(name: AppRoutes.search, page: () => const SearchView()),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.teacherSettings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.studentsList,
      page: () => const StudentListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StudentListController());
      }),
    ),
    GetPage(
      name: AppRoutes.studentDetail,
      page: () => const StudentDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StudentDetailController());
      }),
    ),
    GetPage(
      name: AppRoutes.evaluation,
      page: () => const EvaluationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EvaluationController());
      }),
    ),
    GetPage(
      name: AppRoutes.studentBadges,
      page: () => const BadgesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BadgesController());
      }),
      middlewares: [
        RoleMiddleware(allowedRoles: ['student']),
      ],
    ),
  ];
}
