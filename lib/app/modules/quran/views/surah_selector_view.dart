import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quran_controller.dart';
import 'quran_reader_view.dart';

/// Surah selector view
class SurahSelectorView extends GetView<QuranController> {
  const SurahSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => QuranController());

    return Scaffold(
      appBar: AppBar(title: Text('quran'.tr)),
      body: Obx(() {
        if (controller.isLoading.value && controller.surahs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.surahs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                Text('no_quran_data'.tr),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.surahs.length,
          itemBuilder: (context, index) {
            final surah = controller.surahs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.surahNumber}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  surah.surahName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${surah.versesCount} آية'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.to(
                  () => QuranReaderView(surahNumber: surah.surahNumber),
                  transition: Transition.cupertino,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
