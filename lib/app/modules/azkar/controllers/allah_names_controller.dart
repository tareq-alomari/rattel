import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/azkar_models.dart';
import '../../../data/providers/database_helper.dart';

class AllahNamesController extends GetxController {
  final RxList<AllahName> allahNames = <AllahName>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    loadAllahNames();
  }

  Future<void> loadAllahNames() async {
    try {
      isLoading.value = true;

      final db = await DatabaseHelper.instance.database;
      final results = await db.query('allah_names', orderBy: 'number ASC');

      if (results.isEmpty) {
        debugPrint('⚠️ No Allah names found in database');
        isLoading.value = false;
        return;
      }

      allahNames.value = results.map((map) {
        return AllahName(
          name: map['name'] as String? ?? '',
          transliteration: map['transliteration'] as String? ?? '',
          number: map['number'] as int? ?? 0,
          enMeaning: map['en_meaning'] as String? ?? '',
          found: map['found'] as String? ?? '',
        );
      }).toList();

      debugPrint('✅ Loaded ${allahNames.length} Allah names from database');
      isLoading.value = false;
    } catch (e) {
      debugPrint('❌ Error loading Allah names: $e');
      isLoading.value = false;
      Get.snackbar('خطأ', 'فشل تحميل أسماء الله الحسنى: $e');
    }
  }

  void selectName(int index) {
    selectedIndex.value = index;
  }
}
