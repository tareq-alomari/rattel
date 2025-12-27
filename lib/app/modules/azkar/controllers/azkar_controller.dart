import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/azkar_models.dart';
import '../../../data/providers/database_helper.dart';

class AzkarController extends GetxController {
  final RxList<Zekr> allAzkar = <Zekr>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = 'أذكار الصباح'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAzkar();
  }

  Future<void> loadAzkar() async {
    try {
      isLoading.value = true;

      final db = await DatabaseHelper.instance.database;
      final results = await db.query('azkar');

      if (results.isEmpty) {
        debugPrint('⚠️ No azkar found in database');
        isLoading.value = false;
        return;
      }

      allAzkar.value = results.map((map) {
        return Zekr(
          category: map['category'] as String? ?? '',
          zekr: map['zekr'] as String? ?? '',
          description: map['description'] as String? ?? '',
          reference: map['reference'] as String? ?? '',
          count: map['count'] as String? ?? '1',
        );
      }).toList();

      // Extract unique categories
      final Set<String> uniqueCategories = {};
      for (var zekr in allAzkar) {
        if (zekr.category.isNotEmpty) {
          uniqueCategories.add(zekr.category);
        }
      }
      categories.value = uniqueCategories.toList();

      debugPrint('✅ Loaded ${allAzkar.length} azkar from database');
      isLoading.value = false;
    } catch (e) {
      debugPrint('❌ Error loading azkar: $e');
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل تحميل الأذكار: $e');
    }
  }

  List<Zekr> getAzkarByCategory(String category) {
    return allAzkar.where((zekr) => zekr.category == category).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
