import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tajweed_controller.dart';
import 'rule_detail_view.dart';

class TajweedRulesListView extends GetView<TajweedController> {
  const TajweedRulesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.currentCategoryTitle.value.tr)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.rules.isEmpty) {
          return const Center(child: Text('No rules found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.rules.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final rule = controller.rules[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  rule.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.to(() => RuleDetailView(rule: rule));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
