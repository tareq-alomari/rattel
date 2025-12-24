import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/student_controller.dart';

/// Badges view for students
class BadgesView extends StatelessWidget {
  const BadgesView({super.key});

  @override
  Widget build(BuildContext context) {
    final studentController = Get.find<StudentController>();

    return Scaffold(
      appBar: AppBar(title: Text('badges'.tr)),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, size: 48, color: Colors.amber),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'earned_badges'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${studentController.totalBadges.value}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Badges grid
              Text(
                'all_badges'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildBadgeCard(
                    context,
                    'first_verse'.tr,
                    Icons.star,
                    Colors.blue,
                    studentController.totalVersesMemorized.value >= 1,
                  ),
                  _buildBadgeCard(
                    context,
                    '10_verses'.tr,
                    Icons.stars,
                    Colors.green,
                    studentController.totalVersesMemorized.value >= 10,
                  ),
                  _buildBadgeCard(
                    context,
                    '50_verses'.tr,
                    Icons.auto_awesome,
                    Colors.purple,
                    studentController.totalVersesMemorized.value >= 50,
                  ),
                  _buildBadgeCard(
                    context,
                    '100_verses'.tr,
                    Icons.emoji_events,
                    Colors.orange,
                    studentController.totalVersesMemorized.value >= 100,
                  ),
                  _buildBadgeCard(
                    context,
                    '7_day_streak'.tr,
                    Icons.local_fire_department,
                    Colors.red,
                    studentController.currentStreak.value >= 7,
                  ),
                  _buildBadgeCard(
                    context,
                    '30_day_streak'.tr,
                    Icons.whatshot,
                    Colors.deepOrange,
                    studentController.currentStreak.value >= 30,
                  ),
                  _buildBadgeCard(
                    context,
                    'first_juz'.tr,
                    Icons.book,
                    Colors.teal,
                    studentController.completionPercentage.value >= 3.3,
                  ),
                  _buildBadgeCard(
                    context,
                    'half_quran'.tr,
                    Icons.menu_book,
                    Colors.indigo,
                    studentController.completionPercentage.value >= 50,
                  ),
                  _buildBadgeCard(
                    context,
                    'full_quran'.tr,
                    Icons.workspace_premium,
                    Colors.amber,
                    studentController.completionPercentage.value >= 100,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBadgeCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isEarned,
  ) {
    return Card(
      elevation: isEarned ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isEarned
              ? LinearGradient(
                  colors: [color.withOpacity(0.7), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isEarned ? Colors.white : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                color: isEarned ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
