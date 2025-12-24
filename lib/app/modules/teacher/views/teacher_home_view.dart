import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/teacher_main_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

/// Teacher home view with dashboard
class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherController = Get.put(TeacherController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('teacher_dashboard'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => teacherController.refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => teacherController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (teacherController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => teacherController.refresh(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(
                            authController.fullName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'welcome'.tr + ', ${authController.fullName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                teacherController.performanceSummary,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Statistics cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'total_students'.tr,
                        teacherController.totalStudents.value.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'active_students'.tr,
                        teacherController.activeStudents.value.toString(),
                        Icons.trending_up,
                        Colors.green,
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
                        'evaluations'.tr,
                        teacherController.totalEvaluations.value.toString(),
                        Icons.assignment_turned_in,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'avg_score'.tr,
                        teacherController.averageScore.value.toStringAsFixed(1),
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // View All Students Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      try {
                        Get.find<TeacherMainController>().changeTab(2);
                      } catch (e) {
                        // Fallback navigation if controller not found (e.g. testing)
                        Get.toNamed(AppRoutes.studentsList);
                      }
                    },
                    icon: const Icon(Icons.people),
                    label: Text('view_all_students'.tr),
                  ),
                ),
                const SizedBox(height: 20),

                // Activity rate card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'student_activity_rate'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: teacherController.activityRate / 100,
                            minHeight: 12,
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${teacherController.activityRate.toStringAsFixed(1)}% ${'active_last_week'.tr}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Recent evaluations message
                // Recent Activity
                Text(
                  'recent_activity'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (teacherController.recentActivity.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'no_recent_activity'.tr,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: teacherController.recentActivity.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final activity =
                            teacherController.recentActivity[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: const Icon(
                              Icons.history,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(activity['student_name'] ?? 'Unknown'),
                          subtitle: Text(
                            '${'memorized_verses'.tr}: ${activity['to_ayah'] - activity['from_ayah'] + 1} (${activity['surah_name_en'] ?? activity['surah_name'] ?? ''})',
                          ),
                          trailing: Text(
                            _formatDate(activity['date']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                // Recent Evaluations
                Text(
                  'evaluations'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (teacherController.recentEvaluations.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'no_recent_evaluations'.tr,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: teacherController.recentEvaluations.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final eval = teacherController.recentEvaluations[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            child: const Icon(Icons.star, color: Colors.orange),
                          ),
                          title: Text(eval['student_name'] ?? 'Unknown'),
                          subtitle: Text(
                            '${'score'.tr}: ${eval['score']} - ${eval['notes'] ?? ''}',
                          ),
                          trailing: Text(
                            _formatDate(eval['created_at']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
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

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) return 'today'.tr;
      if (diff.inDays == 1) return 'yesterday'.tr;
      if (diff.inDays < 7) return '${diff.inDays} ${'days_ago'.tr}';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
