import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/student_detail_controller.dart';

/// Student detail view
class StudentDetailView extends StatelessWidget {
  const StudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentDetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('ملف الطالب')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final student = controller.student;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              _buildProfileHeader(context, student),
              const SizedBox(height: 24),

              // Progress Stats
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      title: 'الآيات المحفوظة',
                      value: '${student['total_verses'] ?? 0}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      title: 'السور المكتملة',
                      value: '${student['completed_surahs'] ?? 0}',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Evaluation Button
              ElevatedButton.icon(
                onPressed: () {
                  if (student['user_id'] != null) {
                    Get.toNamed(
                      AppRoutes.evaluation.replaceFirst(
                        ':id',
                        '${student['user_id']}',
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.rate_review),
                label: const Text('إضافة تقييم'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    Map<String, dynamic> student,
  ) {
    final avatarColor = Colors
        .primaries[(student['name'] ?? 'A').hashCode % Colors.primaries.length];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: avatarColor.withValues(alpha: 0.1),
            child: Text(
              (student['name'] as String? ?? 'A')[0].toUpperCase(),
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            student['name'] ?? 'اسم الطالب',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            student['email'] ?? '',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
