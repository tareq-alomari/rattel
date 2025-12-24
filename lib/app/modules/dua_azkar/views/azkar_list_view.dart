import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dua_controller.dart';
import '../../../data/models/dua_model.dart';

class AzkarListView extends StatelessWidget {
  final String category;
  final String title;

  const AzkarListView({super.key, required this.category, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DuaController());
    controller.loadDuasByCategory(category);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.duas.isEmpty) {
          return Center(
            child: Text(
              'no_data'.tr,
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.duas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final dua = controller.duas[index];
            return _buildDuaCard(context, controller, dua);
          },
        );
      }),
    );
  }

  Widget _buildDuaCard(
    BuildContext context,
    DuaController controller,
    DuaModel dua,
  ) {
    final theme = Theme.of(context);
    final count = dua.count ?? 1;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (dua.id != null) {
            controller.incrementCounter(dua.id!, count);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${dua.count} ${'times'.tr}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (dua.source != null)
                    Text(
                      dua.source!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Dua Text
              Text(
                dua.duaText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Amiri', // Assuming you have this font or similar
                ),
              ),

              if (dua.translation != null && dua.translation!.isNotEmpty) ...[
                const Divider(height: 32),
                Text(
                  dua.translation!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],

              const SizedBox(height: 24),

              // Counter Progress
              Obx(() {
                final duaId = dua.id ?? 0;
                final current = controller.counters[duaId] ?? 0;
                final progress = controller.getProgress(duaId, count);
                final isCompleted = current >= count;

                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted
                              ? Colors.green
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isCompleted)
                          const Icon(Icons.check_circle, color: Colors.green)
                        else
                          Text(
                            '$current / $count',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    if (!isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'tap_to_count'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
