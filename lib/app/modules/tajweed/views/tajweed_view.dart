import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rattel/app/modules/tajweed/views/tajweed_rules_list_view.dart';
import '../controllers/tajweed_controller.dart';

class TajweedView extends StatelessWidget {
  const TajweedView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TajweedController());
    final theme = Theme.of(context);

    // List of categories to display
    final categories = [
      {'id': 'noon_saakin', 'color': Colors.blue, 'icon': Icons.blur_circular},
      {
        'id': 'meem_saakin',
        'color': Colors.teal,
        'icon': Icons.circle_outlined,
      },
      {'id': 'madd', 'color': Colors.purple, 'icon': Icons.graphic_eq},
      {'id': 'qalqalah', 'color': Colors.orange, 'icon': Icons.vibration},
      {
        'id': 'makharij',
        'color': Colors.brown,
        'icon': Icons.record_voice_over,
      },
      {'id': 'sifaat', 'color': Colors.indigo, 'icon': Icons.tune},
      {'id': 'raa_rules', 'color': Colors.deepOrange, 'icon': Icons.explicit},
      {
        'id': 'lam_rules',
        'color': Colors.cyan,
        'icon': Icons.looks_one,
      }, // Placeholder icon
      {'id': 'hamzat_wasl', 'color': Colors.grey, 'icon': Icons.link},
      {'id': 'stopping', 'color': Colors.red, 'icon': Icons.stop_circle},
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text('tajweed_rules'.tr),
            centerTitle: true,
            expandedHeight: 140, // Slightly reduced
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85, // Taller cards
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final cat = categories[index];
                return _buildGridCard(
                  context,
                  cat['id'] as String,
                  cat['id'] as String,
                  cat['icon'] as IconData,
                  cat['color'] as Color,
                );
              }, childCount: categories.length),
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    String id,
    String titleKey,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.cardColor,
      child: InkWell(
        onTap: () {
          final controller = Get.find<TajweedController>();
          controller.loadRules(id, titleKey);
          Get.to(() => const TajweedRulesListView());
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                titleKey.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${id}_desc'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
