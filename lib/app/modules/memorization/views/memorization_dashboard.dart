import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/memorization_controller.dart';
import '../../../data/models/memorization_models.dart';

class MemorizationDashboardView extends GetView<MemorizationController> {
  const MemorizationDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memorization Dashboard'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activePlans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.note_alt_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text('No active memorization plans'.tr),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreatePlanDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text('Create New Plan'.tr),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activePlans.length,
          itemBuilder: (context, index) {
            final plan = controller.activePlans[index];
            return _buildPlanCard(context, plan);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlanDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, MemorizationPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              plan.name,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'daily_target_status'.trParams({
                'target': controller.getDailyTarget(plan),
              }),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.3, // Placeholder
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to details
                },
                child: Text('View Details'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context) {
    // Placeholder for create dialog
    // In a real app, this would be a full screen or robust bottom sheet
    final nameController = TextEditingController();
    Get.defaultDialog(
      title: 'New Plan',
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Plan Name'),
          ),
          // Add more fields for start/end surah/ayah
        ],
      ),
      textConfirm: 'Create',
      textCancel: 'Cancel',
      onConfirm: () {
        if (nameController.text.isNotEmpty) {
          controller.createPlan(
            MemorizationPlan(
              name: nameController.text,
              startDate: DateTime.now(),
              targetDate: DateTime.now().add(const Duration(days: 30)),
              startSurah: 1,
              startAyah: 1,
              endSurah: 2, // Dummy
              endAyah: 1,
              dailyAmountPages: 1,
            ),
          );
        }
      },
    );
  }
}
