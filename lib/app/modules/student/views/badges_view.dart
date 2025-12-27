import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/badges_controller.dart';

/// Badges view for students
class BadgesView extends GetView<BadgesController> {
  const BadgesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('badges'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allBadges.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'لا توجد شارات متاحة',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 32, color: Colors.amber),
                  const SizedBox(width: 12),
                  Text(
                    '${controller.earnedCount} / ${controller.totalCount}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(width: 8),
                  const Text('شارة'),
                ],
              ),
            ),

            // Badges Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: controller.allBadges.length,
                itemBuilder: (context, index) {
                  final badge = controller.allBadges[index];
                  return _BadgeCard(badge: badge);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final dynamic badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isEarned = badge.isEarned;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEarned
            ? Colors.amber.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? Colors.amber : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 48,
            color: isEarned ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            badge.badgeName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isEarned ? Colors.black87 : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isEarned ? Colors.grey.shade600 : Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isEarned) ...[
            const SizedBox(height: 8),
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ],
      ),
    );
  }
}
