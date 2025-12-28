import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_drawer.dart';
import '../controllers/azkar_controller.dart';

class AzkarView extends GetView<AzkarController> {
  const AzkarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'daily_azkar'.tr,
          style: GoogleFonts.cairo(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                'azkar_subtitle'.tr,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              // Category Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _CategoryCard(
                    key: const Key('azkar_morning'),
                    title: 'morning_azkar'.tr,
                    icon: Icons.wb_sunny,
                    color: AppColors.azkarPurple,
                    onTap: () => _showAzkarList(context, 'أذكار الصباح'),
                  ),
                  _CategoryCard(
                    key: const Key('azkar_evening'),
                    title: 'evening_azkar'.tr,
                    icon: Icons.nightlight,
                    color: AppColors.azkarOrange,
                    onTap: () => _showAzkarList(context, 'أذكار المساء'),
                  ),
                  _CategoryCard(
                    title: 'prayer_azkar'.tr,
                    icon: Icons.favorite,
                    color: AppColors.azkarGreen,
                    onTap: () => _showAzkarList(context, 'أذكار الصلاة'),
                  ),
                  _CategoryCard(
                    title: 'sleep_azkar'.tr,
                    icon: Icons.bedtime,
                    color: AppColors.azkarCyan,
                    onTap: () => _showAzkarList(context, 'أذكار النوم'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Access Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'azkar_title'.tr,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'view_all'.tr,
                      style: GoogleFonts.cairo(
                        color: AppColors.teacherPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Sample Azkar Cards
              ...controller.allAzkar.take(3).map((zekr) {
                return _buildZekrCard(
                  context,
                  zekr,
                  controller.allAzkar.indexOf(zekr),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  void _showAzkarList(BuildContext context, String category) {
    controller.selectCategory(category);
    Get.to(() => AzkarListView(category: category));
  }

  Widget _buildZekrCard(BuildContext context, dynamic zekr, int index) {
    final colors = [
      const Color(0xFFFEF3C7),
      const Color(0xFFDCFCE7),
      const Color(0xFFE0E7FF),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.azkarOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              zekr.category,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Zekr Text
          Text(
            zekr.zekr,
            style: GoogleFonts.amiri(
              fontSize: 18,
              height: 1.8,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (zekr.count.isNotEmpty)
                Text(
                  zekr.count,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              Text(
                '0 / ${zekr.count.isNotEmpty ? zekr.count : "1"}',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Azkar List View
class AzkarListView extends GetView<AzkarController> {
  final String category;

  const AzkarListView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final azkar = controller.getAzkarByCategory(category);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          category,
          style: GoogleFonts.cairo(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: azkar.length,
        itemBuilder: (context, index) {
          final zekr = azkar[index];
          return _ZekrDetailCard(zekr: zekr, index: index);
        },
      ),
    );
  }
}

class _ZekrDetailCard extends StatefulWidget {
  final dynamic zekr;
  final int index;

  const _ZekrDetailCard({required this.zekr, required this.index});

  @override
  State<_ZekrDetailCard> createState() => _ZekrDetailCardState();
}

class _ZekrDetailCardState extends State<_ZekrDetailCard> {
  int currentCount = 0;

  @override
  Widget build(BuildContext context) {
    final totalCount = int.tryParse(widget.zekr.count) ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.zekr.category,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '$currentCount / $totalCount',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Zekr Text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.zekr.zekr,
              style: GoogleFonts.amiri(
                fontSize: 20,
                height: 2.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          if (widget.zekr.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.zekr.description,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action Button
          ElevatedButton(
            onPressed: currentCount < totalCount
                ? () {
                    setState(() {
                      currentCount++;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              currentCount >= totalCount
                  ? 'completed_count'.trParams({'count': '$totalCount'})
                  : 'press_to_count'.trParams({'count': '$totalCount'}),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
