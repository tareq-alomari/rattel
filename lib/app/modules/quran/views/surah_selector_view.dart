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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('quran'.tr),
          bottom: TabBar(
            tabs: [
              Tab(text: 'surah'.tr),
              Tab(text: 'juz'.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildSurahList(context), _buildJuzList(context)],
        ),
      ),
    );
  }

  Widget _buildSurahList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.surahs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.surahs.isEmpty) {
        return _buildEmptyState();
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
              subtitle: Text('${surah.versesCount} ${'ayah'.tr}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.to(
                () => QuranReaderView(surahNumber: surah.surahNumber),
                transition: Transition.cupertino,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildJuzList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.juzInfo.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.juzInfo.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.juzInfo.length,
        itemBuilder: (context, index) {
          final info = controller.juzInfo[index];
          final juzNum = info['juz'];
          final startPage = info['page'];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$juzNum',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text('${'juz'.tr} $juzNum'),
              subtitle: Text('${'page'.tr} $startPage'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.to(
                () => QuranReaderView(
                  surahNumber: 1, // Placeholder
                  initialPageNumber: startPage,
                ),
                transition: Transition.cupertino,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
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
}
