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

    // List of categories with gradient colors
    final categories = [
      {
        'id': 'noon_saakin',
        'colors': [Colors.blue.shade400, Colors.blue.shade700],
        'icon': Icons.blur_circular,
      },
      {
        'id': 'meem_saakin',
        'colors': [Colors.teal.shade400, Colors.teal.shade700],
        'icon': Icons.circle_outlined,
      },
      {
        'id': 'madd',
        'colors': [Colors.purple.shade400, Colors.purple.shade700],
        'icon': Icons.graphic_eq,
      },
      {
        'id': 'qalqalah',
        'colors': [Colors.orange.shade400, Colors.orange.shade700],
        'icon': Icons.vibration,
      },
      {
        'id': 'makharij',
        'colors': [Colors.brown.shade400, Colors.brown.shade700],
        'icon': Icons.record_voice_over,
      },
      {
        'id': 'sifaat',
        'colors': [Colors.indigo.shade400, Colors.indigo.shade700],
        'icon': Icons.tune,
      },
      {
        'id': 'raa_rules',
        'colors': [Colors.deepOrange.shade400, Colors.deepOrange.shade700],
        'icon': Icons.explicit,
      },
      {
        'id': 'lam_rules',
        'colors': [Colors.cyan.shade400, Colors.cyan.shade700],
        'icon': Icons.looks_one,
      },
      {
        'id': 'hamzat_wasl',
        'colors': [Colors.blueGrey.shade400, Colors.blueGrey.shade700],
        'icon': Icons.link,
      },
      {
        'id': 'stopping',
        'colors': [Colors.red.shade400, Colors.red.shade700],
        'icon': Icons.stop_circle,
      },
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'tajweed_rules'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            expandedHeight: 120,
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, // Tuned for mobile responsiveness
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85, // Slightly taller for text
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final cat = categories[index];
                return _buildGradientCard(
                  context,
                  cat['id'] as String,
                  cat['id'] as String,
                  cat['icon'] as IconData,
                  cat['colors'] as List<Color>,
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

  Widget _buildGradientCard(
    BuildContext context,
    String id,
    String titleKey,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  titleKey.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: 0.9,
                  child: Text(
                    '${id}_desc'.tr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
