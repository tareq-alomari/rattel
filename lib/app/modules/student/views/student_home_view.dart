import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/student_controller.dart';

/// Student home dashboard matching reference design
class StudentHomeView extends GetView<StudentController> {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().currentUser.value;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'P',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, color: AppColors.primaryLight, size: 24),
            const SizedBox(width: 8),
            Text(
              'app_name'.tr,
              style: GoogleFonts.cairo(
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Obx(() => PointsBadge(points: controller.totalPoints.value)),
          const SizedBox(width: 8),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimaryLight),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadStudentData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card (matching reference image 3)
              _buildProfileCard(user?.name ?? 'محمد أحمد'),
              const SizedBox(height: 24),

              // Achievements Badges Section
              SectionHeader(
                title: 'earned_badges'.tr,
                icon: Icons.emoji_events,
                iconColor: AppColors.accent,
              ),
              const SizedBox(height: 12),
              _buildAchievementsBadges(),
              const SizedBox(height: 24),

              // Statistics Section
              SectionHeader(
                title: 'statistics'.tr,
                icon: Icons.bar_chart,
                iconColor: AppColors.iconGreen,
              ),
              const SizedBox(height: 12),
              _buildStatisticsSection(),
              const SizedBox(height: 24),

              // Quick Actions
              SectionHeader(
                title: 'quick_actions'.tr,
                icon: Icons.flash_on,
                iconColor: AppColors.iconOrange,
              ),
              const SizedBox(height: 12),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Profile card matching reference design (image 3)
  Widget _buildProfileCard(String name) {
    return AppCard(
      color: AppColors.primaryLight,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'student_in_circle'.tr,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                GetBuilder<StudentController>(
                  init: StudentController(),
                  builder: (ctrl) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'points_text'.trParams({
                            'points': '${ctrl.totalPoints.value}',
                          }),
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
                const SizedBox(height: 8),
                GetBuilder<StudentController>(
                  init: StudentController(),
                  builder: (ctrl) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'days_streak'.trParams({
                            'days': '${ctrl.currentStreak.value}',
                          }),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'level_number'.trParams({'level': '5'}),
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: GoogleFonts.cairo(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Achievements badges (matching reference image 3)
  Widget _buildAchievementsBadges() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        AchievementBadge(
          icon: Icons.emoji_events,
          title: 'badge_excellent_memorizer'.tr,
          subtitle: '',
          backgroundColor: AppColors.badgeYellow,
          iconColor: Colors.orange,
        ),
        AchievementBadge(
          icon: Icons.local_fire_department,
          title: 'badge_consistent'.tr,
          subtitle: '',
          backgroundColor: AppColors.badgeOrange,
          iconColor: Colors.deepOrange,
        ),
        AchievementBadge(
          icon: Icons.menu_book,
          title: 'badge_excellent_reader'.tr,
          subtitle: '',
          backgroundColor: AppColors.badgeGreen,
          iconColor: AppColors.primaryLight,
          isActive: false,
        ),
        AchievementBadge(
          icon: Icons.star,
          title: 'badge_active_reviewer'.tr,
          subtitle: '',
          backgroundColor: AppColors.badgePurple,
          iconColor: AppColors.iconPurple,
        ),
      ],
    );
  }

  /// Statistics section (matching reference image 3)
  Widget _buildStatisticsSection() {
    return AppCard(
      child: Obx(
        () => Column(
          children: [
            ProgressBarWidget(
              label: 'memorization_label'.tr,
              current: controller.pagesMemorized.value,
              total: 30,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: 16),
            ProgressBarWidget(
              label: 'review_label'.tr,
              current: controller.pagesReviewed.value,
              total: 50,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            ProgressBarWidget(
              label: 'commitment_label'.tr,
              current: controller.currentStreak.value > 0 ? 95 : 0,
              total: 100,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// Quick actions grid
  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          icon: Icons.book,
          title: 'quran_action'.tr,
          color: AppColors.iconGreen,
          onTap: () => Get.toNamed(AppRoutes.surahSelector),
        ),
        _buildActionCard(
          icon: Icons.article,
          title: 'hadith_action'.tr,
          color: AppColors.iconOrange,
          onTap: () => Get.toNamed(AppRoutes.hadith),
        ),
        _buildActionCard(
          icon: Icons.favorite,
          title: 'azkar_action'.tr,
          color: AppColors.iconPurple,
          onTap: () => Get.toNamed(AppRoutes.azkar),
        ),
        _buildActionCard(
          icon: Icons.star,
          title: 'allah_names_action'.tr,
          color: AppColors.iconBlue,
          onTap: () => Get.toNamed(AppRoutes.allahNames),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
