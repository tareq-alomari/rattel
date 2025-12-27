import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../controllers/teacher_controller.dart';
import '../widgets/dashboard_widgets.dart';

/// Teacher Home View
class TeacherHomeView extends GetView<TeacherController> {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, color: AppColors.teacherPrimary, size: 24),
            const SizedBox(width: 8),
            Text(
              'app_name'.tr,
              style: GoogleFonts.cairo(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return LoadingWidget(message: 'loading'.tr);
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return ErrorRetryWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshDashboard,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.teacherPrimary,
                      AppColors.teacherPrimaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'peace_be_upon'.trParams({'name': 'أستاذ'}),
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'teacher_description'.tr,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          'م',
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'stat_students'.tr,
                      value: '${controller.totalStudents.value}',
                      icon: Icons.people,
                      color: AppColors.statBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'stat_circles'.tr,
                      value: '${controller.halaqahCount.value}',
                      icon: Icons.groups,
                      color: AppColors.statPurple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'stat_points'.tr,
                      value: '${controller.points.value}',
                      icon: Icons.star,
                      color: AppColors.statOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'stat_streak_days'.tr,
                      value: '${controller.streakDays.value}',
                      icon: Icons.local_fire_department,
                      color: AppColors.statRed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Row(
                children: [
                  const Icon(Icons.flash_on, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Text(
                    'الإجراءات السريعة',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  QuickActionCard(
                    title: 'record_attendance'.tr,
                    icon: Icons.check_circle,
                    color: AppColors.teacherPrimaryDark,
                    onTap: () {},
                  ),
                  QuickActionCard(
                    title: 'evaluate_student'.tr,
                    icon: Icons.assessment,
                    color: const Color(0xFF3B82F6),
                    onTap: () {},
                  ),
                  QuickActionCard(
                    title: 'schedule_session'.tr,
                    icon: Icons.event,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Get.toNamed('/teacher/halaqat'),
                  ),
                  QuickActionCard(
                    title: 'send_report'.tr,
                    icon: Icons.send,
                    color: const Color(0xFFF59E0B),
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Upcoming Sessions - Keeping hardcoded for now as example or could be dynamic if we had session logic
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Text(
                    'الحصص القادمة',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (controller.upcomingSessions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'no_upcoming_sessions'.tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.upcomingSessions.length,
                  itemBuilder: (context, index) {
                    final session = controller.upcomingSessions[index];
                    final date = DateTime.parse(session['date']);
                    final timeStr =
                        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SessionCard(
                        title: session['halaqah_name'] ?? 'halaqah'.tr,
                        time: timeStr,
                        students:
                            '${session['student_count'] ?? 0} ${'student'.tr}',
                        color: index % 2 == 0
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF8B5CF6),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Achievements
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Text(
                    'الإنجازات والشارات',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  AchievementBadge(
                    title: 'badge_excellent_teacher'.tr,
                    subtitle: '',
                    icon: Icons.workspace_premium,
                    backgroundColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  AchievementBadge(
                    title: 'badge_consistent'.tr,
                    subtitle: '',
                    icon: Icons.local_fire_department,
                    backgroundColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFEF4444),
                  ),
                  AchievementBadge(
                    title: 'badge_active_reviewer'.tr,
                    subtitle: '',
                    icon: Icons.star,
                    backgroundColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity from Controller
              if (controller.recentActivities.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.history, color: Color(0xFF059669)),
                    const SizedBox(width: 8),
                    Text(
                      'النشاط الأخير',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.recentActivities.length,
                  itemBuilder: (context, index) {
                    final activity = controller.recentActivities[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.check, size: 16),
                        ),
                        title: Text(activity['student_name'] ?? 'طالب'),
                        subtitle: Text(
                          'حفظ ${activity['verses_count'] ?? 0} آيات',
                        ),
                        trailing: Text(
                          (activity['date'] as String).split('T')[0],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
