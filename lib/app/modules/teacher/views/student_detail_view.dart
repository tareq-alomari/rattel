import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/student_detail_controller.dart';
import '../controllers/evaluation_controller.dart';
import '../../../data/models/memorization_models.dart';

class StudentDetailView extends GetView<StudentDetailController> {
  const StudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('student_details'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final student = controller.student;
        if (student.isEmpty) return Center(child: Text('student_not_found'.tr));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        (student['name'] ?? '?')[0].toUpperCase(),
                        style: GoogleFonts.cairo(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student['name'] ?? 'unknown'.tr,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(student['email'] ?? ''),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Active Plans Section
              Text(
                'active_plans'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (controller.studentPlans.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('no_active_plans'.tr),
                  ),
                ),

              ...controller.studentPlans.map(
                (plan) => _buildPlanCard(context, plan),
              ),

              const SizedBox(height: 32),

              // Recent Activity
              Text(
                'recent_logs'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (controller.recentLogs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('no_recent_activity'.tr),
                ),

              ...controller.recentLogs.map(
                (log) => ListTile(
                  title: Text(log.date.toString().substring(0, 10)),
                  subtitle: Text('${log.pagesMemorized} Pages Memorized'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < log.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      // Evaluate Floating Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showEvaluationDialog(context, controller.student['user_id']);
        },
        icon: const Icon(Icons.rate_review),
        label: Text('evaluate'.tr),
      ),
    );
  }

  void _showEvaluationDialog(BuildContext context, int studentId) {
    // Lazily put controller
    final evalController = Get.put(EvaluationController());
    final scoreController = TextEditingController();
    final notesController = TextEditingController();

    Get.defaultDialog(
      title: 'new_evaluation'.tr,
      content: Column(
        children: [
          TextField(
            controller: scoreController,
            decoration: InputDecoration(labelText: 'score_hint'.tr),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            decoration: InputDecoration(labelText: 'notes'.tr),
            maxLines: 3,
          ),
        ],
      ),
      textConfirm: 'submit'.tr,
      textCancel: 'cancel'.tr,
      onConfirm: () {
        final score = double.tryParse(scoreController.text) ?? 0.0;
        evalController.submitEvaluation(
          studentId: studentId,
          score: score,
          notes: notesController.text,
        );
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, MemorizationPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Target: ${plan.targetDate.toString().substring(0, 10)}'),
            LinearProgressIndicator(value: 0.5), // Placeholder
          ],
        ),
      ),
    );
  }
}
