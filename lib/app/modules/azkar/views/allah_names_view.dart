import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_drawer.dart';
import '../controllers/allah_names_controller.dart';

class AllahNamesView extends GetView<AllahNamesController> {
  const AllahNamesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'أسماء الله الحسنى',
                  style: GoogleFonts.cairo(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allahNames.isEmpty) {
          return Center(
            child: Text(
              'لا توجد بيانات',
              style: GoogleFonts.cairo(fontSize: 16),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'إن لله تسعة وتسعين اسماً، مائة إلا واحداً، من أحصاها دخل الجنة',
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Grid of Names
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: controller.allahNames.length,
                itemBuilder: (context, index) {
                  final name = controller.allahNames[index];
                  return _buildNameCard(context, name, index);
                },
              ),

              const SizedBox(height: 24),

              // Footer Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'وصفات الرحيم',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اقرأ أكثر عن أسماء الله الحسنى وصفاته في كل واحد منها',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNameCard(BuildContext context, dynamic name, int index) {
    // 18 different colors for variety
    final colors = [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF10B981), // Green
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF84CC16), // Lime
      const Color(0xFF64748B), // Slate
      const Color(0xFFEC4899), // Pink
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFEC4899), // Pink
    ];

    final color = colors[index % colors.length];

    return GestureDetector(
      key: ValueKey('allah_name_$index'),
      onTap: () => controller.selectName(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Arabic Name
            Text(
              name.name,
              style: GoogleFonts.amiri(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Transliteration (if available)
            Text(
              _getTransliteration(index),
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTransliteration(int index) {
    final transliterations = [
      'الرَّحْمَنُ',
      'الرَّحِيمُ',
      'الْمَلِكُ',
      'الْقُدُّوسُ',
      'السَّلاَمُ',
      'الْمُؤْمِنُ',
      'الْمُهَيْمِنُ',
      'الْعَزِيزُ',
      'الْجَبَّارُ',
      'الْمُتَكَبِّرُ',
      'الْخَالِقُ',
      'الْبَارِئُ',
      'الْمُصَوِّرُ',
      'الْغَفَّارُ',
      'الْقَهَّارُ',
      'الْوَهَّابُ',
      'الرَّزَّاقُ',
      'الْفَتَّاحُ',
    ];

    if (index < transliterations.length) {
      return transliterations[index];
    }
    return '';
  }
}
