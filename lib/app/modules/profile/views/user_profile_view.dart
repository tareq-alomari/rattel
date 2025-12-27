import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/gamification_service.dart';
import '../../../data/models/badge_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../student/controllers/student_controller.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure services are loaded
    if (!Get.isRegistered<GamificationService>()) {
      Get.put(GamificationService());
    }
    final gameService = GamificationService.to;
    final authController = Get.find<AuthController>();

    // Try to get student controller for stats
    StudentController? studentController;
    if (Get.isRegistered<StudentController>()) {
      studentController = Get.find<StudentController>();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('my_profile'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context, authController),
            tooltip: 'edit'.tr,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & User Info
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Text(
                      authController.currentUser.value?.name ?? 'unknown'.tr,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      authController.currentUser.value?.email ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'points_label'.trParams({
                              'points': '${gameService.currentPoints.value}',
                            }),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Statistics Cards
            if (studentController != null) ...[
              Text(
                'statistics'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.book,
                      title: 'memorized_verses'.tr,
                      value: '${studentController.totalVersesMemorized.value}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.local_fire_department,
                      title: 'current_streak'.tr,
                      value: '${studentController.currentStreak.value}',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildStatCard(
                        context,
                        icon: Icons.emoji_events,
                        title: 'badges'.tr,
                        value:
                            '${gameService.allBadges.where((b) => b.isEarned).length}',
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'total_verses'.tr,
                      value: '6236',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Badges Section
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'badges'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),

            Obx(() {
              if (gameService.allBadges.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'earn_badges_hint'.tr,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: gameService.allBadges.length,
                itemBuilder: (context, index) {
                  final badge = gameService.allBadges[index];
                  return _buildBadgeItem(badge);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(BadgeModel badge) {
    final isEarned = badge.isEarned;

    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: isEarned
                ? Colors.amber.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isEarned ? Colors.amber : Colors.grey,
              width: 2,
            ),
          ),
          child: Icon(
            _getBadgeIcon(badge.iconPath ?? ''),
            size: 40,
            color: isEarned ? Colors.amber[800] : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.badgeName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isEarned ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getBadgeIcon(String path) {
    if (path.contains('star')) return Icons.star;
    if (path.contains('medal')) return Icons.military_tech;
    if (path.contains('fire')) return Icons.local_fire_department;
    if (path.contains('book')) return Icons.menu_book;
    return Icons.emoji_events;
  }

  void _showEditProfileDialog(
    BuildContext context,
    AuthController authController,
  ) {
    final nameController = TextEditingController(
      text: authController.currentUser.value?.name ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: Text('edit'.tr + ' ' + 'profile'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'name'.tr,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'email'.tr +
                    ': ${authController.currentUser.value?.email ?? ''}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement update user name in database
              Get.back();
              Get.snackbar(
                'success'.tr,
                'تم تحديث الملف الشخصي',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }
}
