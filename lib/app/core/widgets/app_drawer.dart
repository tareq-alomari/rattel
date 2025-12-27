import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/student/controllers/student_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().currentUser.value;
    final studentController = Get.isRegistered<StudentController>()
        ? Get.find<StudentController>()
        : null;

    return Drawer(
      child: Column(
        children: [
          // Header with user info (matching reference image 2)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'P',
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (studentController != null)
                      GetBuilder<StudentController>(
                        init: studentController,
                        builder: (ctrl) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${ctrl.totalPoints.value}',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'محمد أحمد',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'طالب في حلقة الفجر',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.home,
                  title: 'الرئيسية',
                  isSelected: true,
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.studentHome);
                  },
                ),
                _DrawerItem(
                  icon: Icons.menu_book,
                  title: 'القرآن الكريم',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.surahSelector);
                  },
                ),
                _DrawerItem(
                  icon: Icons.library_books,
                  title: 'الأحاديث',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.hadith);
                  },
                ),
                _DrawerItem(
                  icon: Icons.star,
                  title: 'الحفظ',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.memorization);
                  },
                ),
                _DrawerItem(
                  icon: Icons.wb_sunny,
                  title: 'الأذكار',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.azkar);
                  },
                ),
                _DrawerItem(
                  icon: Icons.auto_awesome,
                  title: 'أسماء الله الحسنى',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.allahNames);
                  },
                ),
                _DrawerItem(
                  icon: Icons.person,
                  title: 'ملفي الشخصي',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/profile');
                  },
                ),
                _DrawerItem(
                  icon: Icons.search,
                  title: 'البحث',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.search);
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.settings);
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              title: Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Get.back();
                Get.find<AuthController>().logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF059669) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.home, color: Colors.white, size: 20)
            : null,
        onTap: onTap,
      ),
    );
  }
}
