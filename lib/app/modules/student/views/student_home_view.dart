import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../quran/views/quran_reader_view.dart';
import '../../leaderboard/views/leaderboard_view.dart';
import 'badges_view.dart';

/// Student home view with statistics dashboard
class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final studentController = Get.put(StudentController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${'welcome'.tr}, ${authController.fullName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => studentController.refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (studentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => studentController.refresh(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                _buildWelcomeCard(context, studentController),
                const SizedBox(height: 16),

                // Continue Reading Card
                if (studentController.lastReadPosition.value != null) ...[
                  _buildContinueReadingCard(context, studentController),
                  const SizedBox(height: 16),
                ],

                // Main statistics cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'total_verses'.tr,
                        studentController.totalVersesMemorized.value.toString(),
                        Icons.menu_book,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'current_streak'.tr,
                        '${studentController.currentStreak.value} ${'days'.tr}',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'badges'.tr,
                        studentController.totalBadges.value.toString(),
                        Icons.emoji_events,
                        Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'completion'.tr,
                        '${studentController.completionPercentage.value.toStringAsFixed(1)}%',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Actions
                Text(
                  'quick_actions'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildQuickActionCard(
                      context,
                      'leaderboard'.tr,
                      Icons.leaderboard_outlined,
                      Colors.orange,
                      () => Get.to(() => const LeaderboardView()),
                    ),
                    _buildQuickActionCard(
                      context,
                      'my_badges'.tr,
                      Icons.stars_outlined,
                      Colors.purple,
                      () => Get.to(() => const BadgesView()),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Progress card
                _buildProgressCard(context, studentController),
                const SizedBox(height: 16),

                // Time-based statistics
                _buildTimeStatsCard(context, studentController),
                const SizedBox(height: 16),

                // Recent activity
                _buildRecentActivityCard(context, studentController),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, StudentController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  controller.hasMemorizedToday
                      ? Icons.check_circle
                      : Icons.info_outline,
                  color: controller.hasMemorizedToday
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.hasMemorizedToday
                        ? 'great_job_today'.tr
                        : 'start_memorizing_today'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              controller.progressMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    StudentController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'overall_progress'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: controller.completionPercentage.value / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.totalVersesMemorized.value} / 6236 ${'verses'.tr}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${controller.completionPercentage.value.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeStatsCard(
    BuildContext context,
    StudentController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'activity_summary'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeStatItem(
                  'today'.tr,
                  controller.versesToday.value.toString(),
                  Icons.today,
                  Colors.blue,
                ),
                _buildTimeStatItem(
                  'this_week'.tr,
                  controller.versesThisWeek.value.toString(),
                  Icons.calendar_view_week,
                  Colors.green,
                ),
                _buildTimeStatItem(
                  'this_month'.tr,
                  controller.versesThisMonth.value.toString(),
                  Icons.calendar_month,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRecentActivityCard(
    BuildContext context,
    StudentController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'recent_activity'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full activity log
                  },
                  child: Text('view_all'.tr),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.recentLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'no_recent_activity'.tr,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ...controller.recentLogs.take(5).map((log) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(log['surah_name']?.toString() ?? 'surah'.tr),
                  subtitle: Text(
                    '${'verses'.tr} ${log['from_ayah']}-${log['to_ayah']}',
                  ),
                  trailing: Text(
                    _formatDate(DateTime.parse(log['date'] as String)),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today'.tr;
    } else if (difference.inDays == 1) {
      return 'yesterday'.tr;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'days_ago'.tr}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    StudentController controller,
  ) {
    final lastRead = controller.lastReadPosition.value!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.to(
            () => QuranReaderView(
              surahNumber: lastRead['surah_number'],
              initialAyahNumber: lastRead['ayah_number'],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'continue_reading'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lastRead['surah_name']} - ${'ayah'.tr} ${lastRead['ayah_number']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
