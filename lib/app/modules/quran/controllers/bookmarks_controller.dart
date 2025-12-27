import 'package:get/get.dart';
import '../../../data/providers/database_helper.dart';

class BookmarksController extends GetxController {
  final RxList<Map<String, dynamic>> bookmarks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    isLoading.value = true;
    try {
      final data = await DatabaseHelper.instance.getBookmarks();
      bookmarks.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bookmarks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBookmark({
    required int surah,
    required int ayah,
    required int page,
    String? name,
  }) async {
    try {
      await DatabaseHelper.instance.addBookmark({
        'surah': surah,
        'ayah': ayah,
        'page': page,
        'created_at': DateTime.now().toIso8601String(),
        // Name is generic for now, can be customized later
      });
      loadBookmarks(); // Refresh list
      Get.snackbar('Saved', 'Bookmark saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save bookmark: $e');
    }
  }

  Future<void> deleteBookmark(int id) async {
    try {
      await DatabaseHelper.instance.deleteBookmark(id);
      bookmarks.removeWhere((b) => b['id'] == id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete bookmark: $e');
    }
  }

  void openBookmark(Map<String, dynamic> bookmark) {
    // Navigate to Quran Reader at specific location
    // Typically: Get.toNamed(Routes.QURAN, arguments: {'page': bookmark['page']});
    // For now, assume we have logic to jump.
    Get.back(result: bookmark); // Return if triggered as selection
    // OR
    // Get.find<QuranController>().jumpToPage(bookmark['page']);
  }
}
