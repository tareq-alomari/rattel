import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dua_controller.dart';

class AzkarStatisticsView extends StatelessWidget {
  const AzkarStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DuaController());
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'azkar_stats'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'daily_progress'.tr,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${controller.dailyCount.value}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Weekly Chart
          SizedBox(
            height: 100,
            child: Obx(() {
              if (controller.weeklyStats.isEmpty) {
                return Center(
                  child: Text(
                    'no_stats_yet'.tr,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                );
              }

              // Find max for scaling
              int maxCount = 1;
              for (var stat in controller.weeklyStats) {
                final count = stat['total'] as int? ?? 0;
                if (count > maxCount) maxCount = count;
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  // Calculate date for label
                  final date = DateTime.now().subtract(
                    Duration(days: 6 - index),
                  );
                  final dateStr = date.toIso8601String().split('T')[0];

                  // Find stat for this date
                  final stat = controller.weeklyStats.firstWhere(
                    (s) => s['date'] == dateStr,
                    orElse: () => {'total': 0},
                  );

                  final count = stat['total'] as int? ?? 0;
                  final heightFactor = count / maxCount;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 8,
                        height: 60 * heightFactor + 4, // Min height 4
                        decoration: BoxDecoration(
                          color: count > 0
                              ? theme.colorScheme.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getDayName(date.weekday),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    // Adjust logic if needed (DateTime.monday is 1)
    return days[weekday - 1].tr;
  }
}
