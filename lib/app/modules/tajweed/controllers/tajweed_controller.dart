import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/tajweed_model.dart';

class TajweedController extends GetxController {
  final DatabaseService _db = DatabaseService.instance;

  final RxList<TajweedModel> rules = <TajweedModel>[].obs;
  final RxBool isLoading = true.obs;

  // Current selected category for display
  final RxString currentCategory = ''.obs;
  final RxString currentCategoryTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _seedData();
  }

  Future<void> _seedData() async {
    await _db.seedTajweedData();
  }

  Future<void> loadRules(String category, String titleKey) async {
    try {
      isLoading.value = true;
      currentCategory.value = category;
      currentCategoryTitle.value = titleKey; // Key for translation

      final data = await _db.getTajweedRules(category);
      rules.assignAll(data);
    } catch (e) {
      print('Error loading rules: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
