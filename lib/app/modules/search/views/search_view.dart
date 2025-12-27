import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as app;

/// Quran search view
class SearchView extends GetView<app.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is injected via binding
    final searchTextController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('search'.tr)),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchTextController,
              decoration: InputDecoration(
                hintText: 'ابحث في القرآن الكريم...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchTextController.clear();
                            controller.clearSearch();
                          },
                        )
                      : const SizedBox(),
                ),
              ),
              onChanged: (value) => controller.searchQuran(value),
              textDirection: TextDirection.rtl,
            ),
          ),

          // Results
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchQuery.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'ابدأ البحث في القرآن الكريم',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد نتائج',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.searchResults.length,
                separatorBuilder: (context, i) => const Divider(),
                itemBuilder: (context, index) {
                  final ayah = controller.searchResults[index];
                  return ListTile(
                    title: Text(
                      ayah.ayahText,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 18),
                    ),
                    subtitle: Text(
                      '${ayah.surahName} - آية ${ayah.ayahNumber}',
                      textDirection: TextDirection.rtl,
                    ),
                    onTap: () => controller.navigateToVerse(
                      ayah.surahNumber,
                      ayah.ayahNumber,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
