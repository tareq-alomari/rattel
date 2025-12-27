import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/app_drawer.dart';
import '../controllers/student_controller.dart';

/// Memorization Journey View - Student's progress tracking
class MemorizationJourneyView extends GetView<StudentController> {
  const MemorizationJourneyView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => StudentController());

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'رحلة الحفظ',
          style: GoogleFonts.cairo(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
            Text(
              'تابع تقدمك في حفظ القرآن الكريم',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // Memorization Card
            _ProgressCard(
              title: 'إجمالي الحفظ',
              value: '12 صفحة',
              color: const Color(0xFF10B981),
              icon: Icons.menu_book,
              progress: 0.12,
            ),

            const SizedBox(height: 12),

            // Review Card
            _ProgressCard(
              title: 'المراجعة',
              value: '25 صفحة',
              color: const Color(0xFF8B5CF6),
              icon: Icons.star,
              progress: 0.25,
            ),

            const SizedBox(height: 12),

            // Commitment Card
            _ProgressCard(
              title: 'الالتزام',
              value: '95%',
              color: const Color(0xFFF59E0B),
              icon: Icons.trending_up,
              progress: 0.95,
            ),

            const SizedBox(height: 24),

            // Weekly Goal Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.track_changes, color: Color(0xFF059669)),
                      const SizedBox(width: 8),
                      Text(
                        'الهدف الأسبوعي',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '35/50',
                    style: GoogleFonts.cairo(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'آية محفوظة هذا الأسبوع',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.7,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'باقي 15 آية لإتمام الهدف',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Daily Schedule Section
            Text(
              'البرنامج اليومي',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _ScheduleItem(
              title: 'الفاتحة',
              subtitle: 'سورة 1 - آية 1-7',
              time: '10%',
              color: const Color(0xFF10B981),
            ),

            const SizedBox(height: 8),

            _ScheduleItem(
              title: 'البقرة',
              subtitle: 'سورة 2 - آية 1-5',
              time: '10%',
              color: const Color(0xFF10B981),
            ),

            const SizedBox(height: 8),

            _ScheduleItem(
              title: 'آل عمران',
              subtitle: 'سورة 3 - آية 1-10',
              time: '10%',
              color: const Color(0xFF10B981),
            ),

            const SizedBox(height: 24),

            // Session Planning Card
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
                    Icons.calendar_today,
                    size: 48,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حصة الحفظ الشخصية',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قريباً سيتم إضافة حصة جديدة مخصصة لك',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'احجز حصة جديدة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final double progress;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ScheduleItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
